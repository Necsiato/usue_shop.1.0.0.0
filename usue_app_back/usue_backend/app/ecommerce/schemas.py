from datetime import datetime
from typing import Dict, List, Optional

from pydantic import BaseModel, Field
from pydantic.config import ConfigDict

from app.core.enums import OrderStatus, UserRole


class CategoryOut(BaseModel):
    slug: str
    title: str
    description: str
    hero_image: str


class ProductOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    description: str
    price: float
    categories: List[str]
    image_urls: List[str] = Field(default_factory=list)
    characteristics: Dict[str, str] = Field(default_factory=dict)
    created_at: float = Field(default_factory=lambda: 0.0)


class ProductCreateRequest(BaseModel):
    id: str
    title: str
    description: str
    category_id: str
    price: float
    image_urls: List[str] = Field(default_factory=list)
    specs: Dict[str, str] = Field(default_factory=dict)


class LoginRequest(BaseModel):
    username: str
    password: str


class RegisterRequest(LoginRequest):
    email: str
    phone: Optional[str] = ""


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    username: str
    full_name: str
    email: str
    role: str
    phone: Optional[str] = ""
    address: Optional[str] = ""


class LoginResponse(BaseModel):
    access_token: str
    user: UserOut


class UserUpdateRequest(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    role: Optional[UserRole] = None


class CartItemPayload(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    product_id: str = Field(alias="productId")
    quantity: int = Field(gt=0, le=99)


class CartEstimateRequest(BaseModel):
    items: List[CartItemPayload]


class CartEstimateResponse(BaseModel):
    total_items: int
    total_sum: float
    currency: str = "RUB"
    breakdown: Dict[str, float]


class OrderItemOut(BaseModel):
    product: ProductOut
    quantity: int
    price: float


class OrderOut(BaseModel):
    id: str
    status: str
    total_sum: float
    created_at: datetime
    customer: UserOut
    items: List[OrderItemOut]


class OrderStatusUpdateRequest(BaseModel):
    status: OrderStatus


class ServiceOut(BaseModel):
    id: str
    title: str
    description: str
    price: float
    status: str
    category_id: Optional[str] = None
    image_url: str


class ServiceCreateRequest(BaseModel):
    id: str
    title: str
    description: str
    price: float
    category_id: Optional[str] = None
    status: str = "new"
    image_url: Optional[str] = ""


class ServiceUpdateRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    status: Optional[str] = None
    category_id: Optional[str] = None
    image_url: Optional[str] = None


class MediaUploadRequest(BaseModel):
    data_url: str = Field(alias="dataUrl")


class MediaUploadResponse(BaseModel):
    url: str
