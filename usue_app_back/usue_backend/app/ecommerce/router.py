import base64
import re
import uuid
from pathlib import Path
from typing import AsyncIterator, Dict, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.auth.utils import decode_jwt, encode_jwt
from app.core.enums import OrderStatus, UserRole
from app.core.security import hash_password, verify_password
from app.db.database import db
from app.models import Category, Order, OrderItem, Product, Service, User
from .schemas import (
    CartEstimateRequest,
    CartEstimateResponse,
    CategoryOut,
    LoginRequest,
    LoginResponse,
    OrderItemOut,
    OrderOut,
    ServiceCreateRequest,
    ServiceOut,
    ServiceUpdateRequest,
    MediaUploadRequest,
    MediaUploadResponse,
    OrderStatusUpdateRequest,
    RegisterRequest,
    ProductCreateRequest,
    ProductOut,
    UserOut,
    UserUpdateRequest,
)

shop_router = APIRouter(prefix="/shop", tags=["shop"])

COOKIE_NAME = "shop_access_token"
STATIC_ROOT = Path(__file__).resolve().parents[1] / "static"
UPLOADS_DIR = STATIC_ROOT / "uploads"
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
MEDIA_UPLOAD_PREFIX = "/static/uploads"
DATA_URL_RE = re.compile(r"^data:image/(png);base64,(?P<data>[A-Za-z0-9+/=]+)$")


async def get_session() -> AsyncIterator[AsyncSession]:
    async for session in db.get_session():
        yield session


def _normalize_category(category_id: str) -> str:
    return category_id.replace("_", "-")


def _save_data_url_file(data_url: str) -> str:
    match = DATA_URL_RE.match(data_url.strip())
    if not match:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Only PNG data URLs are supported")
    try:
        payload = match.group("data")
        binary_data = base64.b64decode(payload)
    except (ValueError, KeyError) as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid image payload") from exc
    file_name = f"media_{uuid.uuid4().hex}.png"
    file_path = UPLOADS_DIR / file_name
    file_path.write_bytes(binary_data)
    return f"{MEDIA_UPLOAD_PREFIX}/{file_name}"


def _map_product(product: Product) -> ProductOut:
    category_slug = product.category.slug if product.category else ""
    return ProductOut(
        id=product.id,
        title=product.title,
        description=product.description,
        price=product.price,
        categories=[category_slug],
        image_urls=product.image_urls or [],
        characteristics=product.characteristics or {},
        created_at=product.created.timestamp() if product.created else 0,
    )


class _VirtualProduct:
    def __init__(self, service: Service):
        self.id = service.id
        self.title = service.title
        self.description = service.description
        self.price = service.price
        self.image_urls = [service.image_url] if service.image_url else []
        self.characteristics = {"type": "service"}
        self.category = service.category


async def _resolve_product_or_service(
    session: AsyncSession,
    product_id: str,
    *,
    ensure_real_product: bool = False,
) -> Optional[Product]:
    product_query = await session.execute(
        select(Product).options(selectinload(Product.category)).where(Product.id == product_id)
    )
    product = product_query.scalar_one_or_none()
    if product:
        return product

    service_query = await session.execute(
        select(Service).options(selectinload(Service.category)).where(Service.id == product_id)
    )
    service = service_query.scalar_one_or_none()
    if not service:
        return None

    if not ensure_real_product:
        return _VirtualProduct(service)  # type: ignore[return-value]

    category_id = service.category_id
    if category_id is None:
        fallback_category = await session.scalar(select(Category.id).limit(1))
        if fallback_category is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No categories found")
        category_id = fallback_category

    product = Product(
        id=service.id,
        category_id=category_id,
        title=service.title,
        description=service.description,
        price=service.price,
        image_urls=[service.image_url] if service.image_url else [],
        characteristics={"type": "service"},
    )
    session.add(product)
    await session.flush()
    result = await session.execute(
        select(Product).options(selectinload(Product.category)).where(Product.id == product.id)
    )
    return result.scalar_one()


async def _get_category_by_slug(session: AsyncSession, category_slug: Optional[str]) -> Optional[Category]:
    if not category_slug:
        return None
    normalized = _normalize_category(category_slug)
    result = await session.execute(select(Category).where(Category.slug == normalized))
    return result.scalar_one_or_none()


def _map_user(user: User) -> UserOut:
    return UserOut(
        id=user.id,
        username=user.username,
        full_name=user.full_name,
        email=user.email,
        role=user.role,
        phone=user.phone,
        address=user.address,
    )


def _map_service(service: Service) -> ServiceOut:
    return ServiceOut(
        id=service.id,
        title=service.title,
        description=service.description,
        price=service.price,
        status=service.status,
        category_id=service.category.slug if service.category else None,
        image_url=service.image_url,
    )


def _map_order(order: Order) -> OrderOut:
    return OrderOut(
        id=order.id,
        status=order.status,
        total_sum=order.total_sum,
        created_at=order.created,
        customer=_map_user(order.user),
        items=[
            OrderItemOut(
                product=_map_product(item.product),
                quantity=item.quantity,
                price=item.price,
            )
            for item in order.items
        ],
    )


async def _get_user_by_username(session: AsyncSession, username: str) -> Optional[User]:
    result = await session.execute(select(User).where(User.username == username))
    return result.scalar_one_or_none()


async def get_current_user(
    request: Request,
    session: AsyncSession = Depends(get_session),
) -> User:
    token = request.cookies.get(COOKIE_NAME)
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication required")
    try:
        payload = decode_jwt(token)
    except Exception as exc:  # pragma: no cover
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    username = payload.get("sub")
    if not username:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
    user = await _get_user_by_username(session, username)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


async def require_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != UserRole.ADMIN.value:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return current_user


@shop_router.get("/categories", response_model=List[CategoryOut])
async def list_categories(session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(Category).order_by(Category.id))
    categories = result.scalars().all()
    return [
        CategoryOut(
            slug=category.slug,
            title=category.title,
            description=category.description,
            hero_image=category.hero_image,
        )
        for category in categories
    ]


@shop_router.get("/products", response_model=List[ProductOut])
async def list_products(category: Optional[str] = None, session: AsyncSession = Depends(get_session)):
    query = select(Product).options(selectinload(Product.category)).order_by(Product.created.desc())
    if category:
        normalized = _normalize_category(category)
        query = query.join(Product.category).where(Category.slug == normalized)
    result = await session.execute(query)
    products = result.scalars().unique().all()
    return [_map_product(product) for product in products]


@shop_router.get("/products/{product_id}", response_model=ProductOut)
async def product_detail(product_id: str, session: AsyncSession = Depends(get_session)):
    result = await session.execute(
        select(Product).options(selectinload(Product.category)).where(Product.id == product_id)
    )
    product = result.scalar_one_or_none()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
    return _map_product(product)


@shop_router.post("/products", response_model=ProductOut)
async def create_product(
    payload: ProductCreateRequest,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin),
):
    normalized_category = _normalize_category(payload.category_id)
    category_result = await session.execute(select(Category).where(Category.slug == normalized_category))
    category = category_result.scalar_one_or_none()
    if not category:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")

    exists = await session.execute(select(Product).where(Product.id == payload.id))
    if exists.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Product already exists")

    product = Product(
        id=payload.id,
        category_id=category.id,
        title=payload.title,
        description=payload.description,
        price=payload.price,
        image_urls=payload.image_urls,
        characteristics=payload.specs,
    )
    session.add(product)
    await session.commit()
    await session.refresh(product)
    return _map_product(product)


@shop_router.get("/services", response_model=List[ServiceOut])
async def list_services(session: AsyncSession = Depends(get_session)):
    result = await session.execute(
        select(Service).options(selectinload(Service.category)).order_by(Service.title)
    )
    services = result.scalars().all()
    return [_map_service(service) for service in services]


@shop_router.post("/services", response_model=ServiceOut, status_code=status.HTTP_201_CREATED)
async def create_service(
    payload: ServiceCreateRequest,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin),
):
    existing = await session.execute(select(Service).where(Service.id == payload.id))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Service already exists")

    category = await _get_category_by_slug(session, payload.category_id)
    service = Service(
        id=payload.id,
        title=payload.title,
        description=payload.description,
        price=payload.price,
        status=payload.status,
        category_id=category.id if category else None,
        image_url=payload.image_url or "",
    )
    session.add(service)
    await session.commit()
    result = await session.execute(
        select(Service).where(Service.id == service.id).options(selectinload(Service.category))
    )
    service = result.scalar_one()
    return _map_service(service)


@shop_router.patch("/services/{service_id}", response_model=ServiceOut)
async def update_service(
    service_id: str,
    payload: ServiceUpdateRequest,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_admin),
):
    result = await session.execute(
        select(Service).where(Service.id == service_id).options(selectinload(Service.category))
    )
    service = result.scalar_one_or_none()
    if not service:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Service not found")

    if payload.title is not None:
        service.title = payload.title
    if payload.description is not None:
        service.description = payload.description
    if payload.price is not None:
        service.price = payload.price
    if payload.status is not None:
        service.status = payload.status
    if payload.image_url is not None:
        service.image_url = payload.image_url
    if payload.category_id is not None:
        category = await _get_category_by_slug(session, payload.category_id)
        service.category_id = category.id if category else None

    await session.commit()
    result = await session.execute(
        select(Service).where(Service.id == service.id).options(selectinload(Service.category))
    )
    service = result.scalar_one()
    return _map_service(service)


@shop_router.post("/media/upload", response_model=MediaUploadResponse, status_code=status.HTTP_201_CREATED)
async def upload_media(
    payload: MediaUploadRequest,
    _: User = Depends(require_admin),
):
    url = _save_data_url_file(payload.data_url)
    return MediaUploadResponse(url=url)


@shop_router.post("/auth/register", response_model=LoginResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: RegisterRequest, response: Response, session: AsyncSession = Depends(get_session)):
    username = payload.username.strip().lower()
    email = payload.email.strip().lower()
    phone = (payload.phone or "").strip()
    if not username or not email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username and email are required")
    existing = await session.execute(select(User).where(User.username == username))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already exists")
    existing_email = await session.execute(select(User).where(User.email == email))
    if existing_email.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

    user = User(
        username=username,
        full_name=username.title(),
        email=email,
        password_hash=hash_password(payload.password),
        role=UserRole.CUSTOMER.value,
        phone=phone,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    token = encode_jwt({"sub": user.username, "role": user.role})
    response.set_cookie(
        key=COOKIE_NAME,
        value=token,
        httponly=True,
        samesite="lax",
        secure=False,
        max_age=60 * 60 * 24 * 7,
    )
    return LoginResponse(access_token=token, user=_map_user(user))


@shop_router.post("/auth/login", response_model=LoginResponse)
async def login(payload: LoginRequest, response: Response, session: AsyncSession = Depends(get_session)):
    username = payload.username.lower()
    user = await _get_user_by_username(session, username)
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid login/password pair")

    token = encode_jwt({"sub": user.username, "role": user.role})
    response.set_cookie(
        key=COOKIE_NAME,
        value=token,
        httponly=True,
        samesite="lax",
        secure=False,
        max_age=60 * 60 * 24 * 7,
    )
    return LoginResponse(access_token=token, user=_map_user(user))


@shop_router.post("/auth/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(response: Response):
    response.delete_cookie(COOKIE_NAME)


@shop_router.get("/auth/me", response_model=LoginResponse)
async def current_user(user: User = Depends(get_current_user)):
    return LoginResponse(access_token="", user=_map_user(user))


@shop_router.post("/cart/estimate", response_model=CartEstimateResponse)
async def estimate_cart(
    payload: CartEstimateRequest,
    _: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    totals: Dict[str, float] = {}
    total_sum = 0.0
    total_items = 0

    for item in payload.items:
        product = await _resolve_product_or_service(session, item.product_id, ensure_real_product=False)
        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Product or service {item.product_id} not found",
            )
        amount = product.price * item.quantity  # type: ignore[attr-defined]
        totals[item.product_id] = amount
        total_sum += amount
        total_items += item.quantity

    return CartEstimateResponse(total_items=total_items, total_sum=total_sum, breakdown=totals)


@shop_router.post(
    "/orders",
    response_model=OrderOut,
    status_code=status.HTTP_201_CREATED,
)
async def create_order(
    payload: CartEstimateRequest,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    product_ids = [item.product_id for item in payload.items]
    products: Dict[str, Product] = {}
    for product_id in set(product_ids):
        product = await _resolve_product_or_service(session, product_id, ensure_real_product=True)
        if not product:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Product or service {product_id} not found",
            )
        products[product_id] = product

    order_id = f"ORD-{uuid.uuid4().hex[:8].upper()}"
    order = Order(id=order_id, user_id=current_user.id, status=OrderStatus.NEW.value, total_sum=0)
    session.add(order)
    await session.flush()

    for item in payload.items:
        product = products[item.product_id]
        line_total = product.price * item.quantity
        order.total_sum += line_total
        session.add(
            OrderItem(order_id=order.id, product_id=product.id, quantity=item.quantity, price=product.price)
        )

    await session.commit()
    result = await session.execute(
        select(Order)
            .where(Order.id == order.id)
            .options(
                selectinload(Order.user),
                selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category),
            )
    )
    order = result.scalar_one()
    return _map_order(order)


@shop_router.patch("/orders/{order_id}", response_model=OrderOut)
async def update_order_status(
    order_id: str,
    payload: OrderStatusUpdateRequest,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    result = await session.execute(
        select(Order)
        .where(Order.id == order_id)
        .options(
            selectinload(Order.user),
            selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category),
        )
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")

    order.status = payload.status.value
    await session.commit()
    await session.refresh(order)
    return _map_order(order)


@shop_router.get("/orders", response_model=List[OrderOut])
async def list_orders(
    customer_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    query = (
        select(Order)
        .options(
            selectinload(Order.user),
            selectinload(Order.items).selectinload(OrderItem.product).selectinload(Product.category),
        )
        .order_by(Order.created.desc())
    )

    requested_id: Optional[int] = None
    if customer_id:
        try:
            requested_id = int(customer_id)
        except ValueError:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid customer id")
    elif current_user.role != UserRole.ADMIN.value:
        requested_id = current_user.id

    if requested_id is not None:
        if current_user.role != UserRole.ADMIN.value and current_user.id != requested_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No access to this user orders")
        query = query.where(Order.user_id == requested_id)

    result = await session.execute(query)
    orders = result.scalars().unique().all()
    return [_map_order(order) for order in orders]


@shop_router.get("/admin/users", response_model=List[UserOut])
async def list_users(
    role: Optional[str] = None,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    query = select(User).order_by(User.created.desc())
    if role:
        query = query.where(User.role == role)
    result = await session.execute(query)
    users = result.scalars().all()
    return [_map_user(user) for user in users]


@shop_router.patch("/admin/users/{user_id}", response_model=UserOut)
async def update_user(
    user_id: int,
    payload: UserUpdateRequest,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    result = await session.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    if payload.username and payload.username != user.username:
        exists = await session.execute(select(User).where(User.username == payload.username))
        if exists.scalar_one_or_none():
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already taken")
        user.username = payload.username

    if payload.password:
        user.password_hash = hash_password(payload.password)

    if payload.phone is not None:
        user.phone = payload.phone

    await session.commit()
    await session.refresh(user)
    return _map_user(user)
