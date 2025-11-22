import random
from typing import Dict, List

from sqlalchemy import func, select

from app.core.enums import OrderStatus, UserRole
from app.core.security import hash_password
from app.models import Category, Order, OrderItem, Product, Service, User
from .database import db

MEDIA_BASE_URL = "/static/media"

CATEGORY_MEDIA = {
    "smart-home": f"{MEDIA_BASE_URL}/categories/smart_home.png",
    "eco-transport": f"{MEDIA_BASE_URL}/categories/eco_transport.png",
    "water-care": f"{MEDIA_BASE_URL}/categories/water_care.png",
    "zero-waste": f"{MEDIA_BASE_URL}/categories/zero_waste.png",
    "urban-farming": f"{MEDIA_BASE_URL}/categories/urban_farming.png",
}

PRODUCT_MEDIA = {
    "smart_home": [
        f"{MEDIA_BASE_URL}/products/smart_home_1.png",
        f"{MEDIA_BASE_URL}/products/smart_home_2.png",
        f"{MEDIA_BASE_URL}/products/smart_home_3.png",
        f"{MEDIA_BASE_URL}/products/smart_home_4.png",
        f"{MEDIA_BASE_URL}/products/smart_home_5.png",
    ],
    "eco_transport": [
        f"{MEDIA_BASE_URL}/products/eco_transport_1.png",
        f"{MEDIA_BASE_URL}/products/eco_transport_2.png",
        f"{MEDIA_BASE_URL}/products/eco_transport_3.png",
        f"{MEDIA_BASE_URL}/products/eco_transport_4.png",
        f"{MEDIA_BASE_URL}/products/eco_transport_5.png",
    ],
    "water_care": [
        f"{MEDIA_BASE_URL}/products/water_care_1.png",
        f"{MEDIA_BASE_URL}/products/water_care_2.png",
        f"{MEDIA_BASE_URL}/products/water_care_3.png",
        f"{MEDIA_BASE_URL}/products/water_care_4.png",
        f"{MEDIA_BASE_URL}/products/water_care_5.png",
    ],
    "zero_waste": [
        f"{MEDIA_BASE_URL}/products/zero_waste_1.png",
        f"{MEDIA_BASE_URL}/products/zero_waste_2.png",
        f"{MEDIA_BASE_URL}/products/zero_waste_3.png",
        f"{MEDIA_BASE_URL}/products/zero_waste_4.png",
        f"{MEDIA_BASE_URL}/products/zero_waste_5.png",
    ],
    "urban_farming": [
        f"{MEDIA_BASE_URL}/products/urban_farming_1.png",
        f"{MEDIA_BASE_URL}/products/urban_farming_2.png",
        f"{MEDIA_BASE_URL}/products/urban_farming_3.png",
        f"{MEDIA_BASE_URL}/products/urban_farming_4.png",
        f"{MEDIA_BASE_URL}/products/urban_farming_5.png",
    ],
}

CATEGORIES_SOURCE = [
    {
        "slug": "smart-home",
        "title": "Smart Home",
        "description": "Controllers, sensors and lighting for efficient homes.",
        "hero_image": CATEGORY_MEDIA["smart-home"],
    },
    {
        "slug": "eco-transport",
        "title": "Eco Transport",
        "description": "Urban bikes, scooters and compact mobility gear.",
        "hero_image": CATEGORY_MEDIA["eco-transport"],
    },
    {
        "slug": "water-care",
        "title": "Water Care",
        "description": "Purifiers, filters and water quality diagnostics.",
        "hero_image": CATEGORY_MEDIA["water-care"],
    },
    {
        "slug": "zero-waste",
        "title": "Zero Waste",
        "description": "Reusable accessories, packaging and kitchen kits.",
        "hero_image": CATEGORY_MEDIA["zero-waste"],
    },
    {
        "slug": "urban-farming",
        "title": "Urban Farming",
        "description": "Indoor gardens, grow-lights and hydroponic kits.",
        "hero_image": CATEGORY_MEDIA["urban-farming"],
    },
]

SERVICES_SOURCE = [
    {
        "id": "install-smart-home",
        "title": "Монтаж умного дома",
        "description": "Выезд инженера, подбор сценариев, настройка шлюзов и датчиков.",
        "price": 14990,
        "status": "in_progress",
        "category": "smart-home",
        "image": "install_smart_home.jpg",
    },
    {
        "id": "eco-audit",
        "title": "Эко-аудит квартиры",
        "description": "Диагностика расхода энергии и воды, подбор экономичных решений.",
        "price": 12990,
        "status": "new",
        "category": "smart-home",
        "image": "eco_audit.jpg",
    },
    {
        "id": "bike-service",
        "title": "Сервис городской техники",
        "description": "Настройка электровелосипедов и самокатов, диагностика батарей.",
        "price": 7990,
        "status": "new",
        "category": "eco-transport",
        "image": "bike_service.jpg",
    },
    {
        "id": "water-lab",
        "title": "Лаборатория воды",
        "description": "Забор проб, анализ состава и подбор фильтров под дом/офис.",
        "price": 9990,
        "status": "new",
        "category": "water-care",
        "image": "water_lab.jpg",
    },
    {
        "id": "urban-garden",
        "title": "Городской огород под ключ",
        "description": "Проектирование гидропонных систем, подсветка, запуск ухода.",
        "price": 18990,
        "status": "in_progress",
        "category": "urban-farming",
        "image": "urban_garden.jpg",
    },
    {
        "id": "zero-waste-kit",
        "title": "Zero-waste внедрение",
        "description": "Переход кафе/офиса на многоразовую тару и раздельный сбор.",
        "price": 15990,
        "status": "new",
        "category": "zero-waste",
        "image": "zero_waste.jpg",
    },
    {
        "id": "smart-training",
        "title": "Обучение персонала",
        "description": "Корпоративные лекции по энергосбережению и ESG-привычкам.",
        "price": 5590,
        "status": "completed",
        "category": "smart-home",
        "image": "training.jpg",
    },
    {
        "id": "rapid-support",
        "title": "Экстренный выезд инженера",
        "description": "24/7 поддержка для B2B-клиентов, восстановление умных систем.",
        "price": 11990,
        "status": "in_progress",
        "category": "smart-home",
        "image": "rapid_support.jpg",
    },
]


def _build_products(category_map: Dict[str, Category]) -> List[Product]:
    base_specs = [
        {"Power": "USB-C", "Warranty": "24 months"},
        {"Material": "Aluminium", "Warranty": "12 months"},
        {"Memory": "64 MB", "Display": "LED"},
        {"Certification": "CE/FCC", "Compatible": "iOS/Android"},
        {"Edition": "2025", "Manufacturer": "USUE"},
    ]
    products: List[Product] = []
    for seed in CATEGORIES_SOURCE:
        category = category_map[seed["slug"]]
        for index in range(5):
            slug = seed["slug"].replace("-", "_")
            product_id = f"{slug}_{index + 1}"
            image_path = f"{MEDIA_BASE_URL}/products/{slug}_{index + 1}.png"
            products.append(
                Product(
                    id=product_id,
                    category_id=category.id,
                    title=f'{seed["title"]} {index + 1}',
                    description=f'{seed["description"]} Edition #{index + 1}.',
                    price=1990 + (index * 1500),
                    image_urls=[image_path],
                    characteristics=base_specs[index % len(base_specs)],
                )
            )
    return products


async def seed_database() -> None:
    async for session in db.get_session():
        category_count = await session.scalar(select(func.count(Category.id)))
        if category_count and category_count > 0:
            return

        categories = [Category(**seed) for seed in CATEGORIES_SOURCE]
        session.add_all(categories)
        await session.flush()
        category_map = {category.slug: category for category in categories}

        products = _build_products(category_map)
        session.add_all(products)
        await session.flush()

        services = []
        for payload in SERVICES_SOURCE:
            category = category_map.get(payload["category"])
            services.append(
                Service(
                    id=payload["id"],
                    title=payload["title"],
                    description=payload["description"],
                    price=payload["price"],
                    status=payload["status"],
                    category_id=category.id if category else None,
                    image_url=f"{MEDIA_BASE_URL}/services/{payload['image']}",
                )
            )
        session.add_all(services)
        await session.flush()

        random.seed(42)
        demo_users: List[User] = [
            User(
                username="user",
                full_name="Demo User",
                email="user@usue.app",
                password_hash=hash_password("user"),
                role=UserRole.CUSTOMER.value,
                phone="+7 900 100-0000",
                address="Ekaterinburg",
            )
        ]
        for index in range(1, 200):
            username = f"user{index:03d}"
            demo_users.append(
                User(
                    username=username,
                    full_name=f"Eco User {index:03d}",
                    email=f"{username}@usue.app",
                    password_hash=hash_password("userpass"),
                    role=UserRole.CUSTOMER.value,
                    phone=f"+7 900 100-{index:04d}",
                    address="Ekaterinburg",
                )
            )

        admin_accounts = [
            ("admin", "admin"),
            ("admin1", "adminpass"),
            ("admin2", "adminpass"),
        ]
        demo_admins: List[User] = []
        for index, (username, password) in enumerate(admin_accounts, start=1):
            demo_admins.append(
                User(
                    username=username,
                    full_name=f"Admin {index}",
                    email=f"{username}@usue.app",
                    password_hash=hash_password(password),
                    role=UserRole.ADMIN.value,
                    phone=f"+7 900 200-{index:04d}",
                    address="HQ office",
                )
            )

        session.add_all(demo_users + demo_admins)
        await session.flush()

        all_products = {product.id: product for product in products}
        orders: List[Order] = []
        order_items: List[OrderItem] = []

        for index in range(1, 151):
            buyer = random.choice(demo_users)
            order_id = f"ORD-{5800 + index}"
            status = random.choice(
                [
                    OrderStatus.NEW.value,
                    OrderStatus.IN_PROGRESS.value,
                    OrderStatus.COMPLETED.value,
                ]
            )
            order = Order(
                id=order_id,
                user_id=buyer.id,
                status=status,
                total_sum=0,
            )
            orders.append(order)

            for _ in range(random.randint(1, 3)):
                product = random.choice(list(all_products.values()))
                quantity = random.randint(1, 3)
                order_items.append(
                    OrderItem(
                        order_id=order_id,
                        product_id=product.id,
                        quantity=quantity,
                        price=product.price,
                    )
                )
                order.total_sum += product.price * quantity

        session.add_all(orders)
        session.add_all(order_items)
        await session.commit()
