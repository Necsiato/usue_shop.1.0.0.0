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
        "title": "Умный дом",
        "description": "Контроллеры, датчики, сценарии и освещение для дома.",
        "hero_image": CATEGORY_MEDIA["smart-home"],
    },
    {
        "slug": "eco-transport",
        "title": "Эко-транспорт",
        "description": "Электробайки, самокаты и городская мобильность.",
        "hero_image": CATEGORY_MEDIA["eco-transport"],
    },
    {
        "slug": "water-care",
        "title": "Чистая вода",
        "description": "Фильтры, очистители и диагностика качества воды.",
        "hero_image": CATEGORY_MEDIA["water-care"],
    },
    {
        "slug": "zero-waste",
        "title": "Zero waste",
        "description": "Многоразовые аксессуары, упаковка и кухонные наборы.",
        "hero_image": CATEGORY_MEDIA["zero-waste"],
    },
    {
        "slug": "urban-farming",
        "title": "Городское фермерство",
        "description": "Домашние грядки, фитолампы и наборы для гидропоники.",
        "hero_image": CATEGORY_MEDIA["urban-farming"],
    },
]

SERVICES_SOURCE = [
    {
        "id": "install-smart-home",
        "title": "Монтаж умного дома",
        "description": "Выезд инженера, настройка сценариев, подключение датчиков и шлюзов.",
        "price": 14990,
        "status": "in_progress",
        "category": "smart-home",
        "image": "install_smart_home.jpg",
    },
    {
        "id": "eco-audit",
        "title": "Эко-аудит помещений",
        "description": "Проверка потребления энергии и ресурсов, подбор решений по экономии.",
        "price": 12990,
        "status": "new",
        "category": "smart-home",
        "image": "eco_audit.jpg",
    },
    {
        "id": "bike-service",
        "title": "Сервис эко-техники",
        "description": "Настройка и диагностика электровелосипедов и самокатов, проверка батарей.",
        "price": 7990,
        "status": "new",
        "category": "eco-transport",
        "image": "bike_service.jpg",
    },
    {
        "id": "water-lab",
        "title": "Лаборатория воды",
        "description": "Отбор проб, анализ качества и рекомендации по фильтрации/очистке.",
        "price": 9990,
        "status": "new",
        "category": "water-care",
        "image": "water_lab.jpg",
    },
    {
        "id": "urban-garden",
        "title": "Городской мини-огород",
        "description": "Подбор домашних грядок: фитолампы, гидропоника, питательные растворы.",
        "price": 18990,
        "status": "in_progress",
        "category": "urban-farming",
        "image": "urban_garden.jpg",
    },
    {
        "id": "zero-waste-kit",
        "title": "Zero waste-набор",
        "description": "Многоразовые бутылки/контейнеры, эко-упаковка и сумки для дома и офиса.",
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
        "title": "Срочная поддержка",
        "description": "24/7 консультации для B2B-клиентов, удалённые проверки и диагностика.",
        "price": 11990,
        "status": "in_progress",
        "category": "smart-home",
        "image": "rapid_support.jpg",
    },
]


def _build_products(category_map: Dict[str, Category]) -> List[Product]:
    base_specs = [
        {"Питание": "USB-C", "Гарантия": "24 месяца"},
        {"Материал": "Алюминий", "Гарантия": "12 месяцев"},
        {"Память": "64 МБ", "Экран": "LED"},
        {"Сертификация": "CE/FCC", "Совместимость": "iOS/Android"},
        {"Серия": "2025", "Производитель": "USUE"},
    ]
    products: List[Product] = []
    for seed in CATEGORIES_SOURCE:
        category = category_map[seed["slug"]]
        for index in range(5):
            slug = seed["slug"].replace("-", "_")  # ASCII для путей
            product_id = f"{slug}_{index + 1}"
            image_path = f"{MEDIA_BASE_URL}/products/{slug}_{index + 1}.png"
            products.append(
                Product(
                    id=product_id,
                    category_id=category.id,
                    title=f'{seed["title"]} {index + 1}',
                    description=f'{seed["description"]} Серия #{index + 1}.',
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
                full_name="Демо пользователь",
                email="user@usue.app",
                password_hash=hash_password("user"),
                role=UserRole.CUSTOMER.value,
                phone="+7 900 100-0000",
                address="Екатеринбург",
            )
        ]
        for index in range(1, 200):
            username = f"user{index:03d}"
            demo_users.append(
                User(
                    username=username,
                    full_name=f"Эко пользователь {index:03d}",
                    email=f"{username}@usue.app",
                    password_hash=hash_password("userpass"),
                    role=UserRole.CUSTOMER.value,
                    phone=f"+7 900 100-{index:04d}",
                    address="Екатеринбург",
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
                    full_name=f"Админ {index}",
                    email=f"{username}@usue.app",
                    password_hash=hash_password(password),
                    role=UserRole.ADMIN.value,
                    phone=f"+7 900 200-{index:04d}",
                    address="Екатеринбург",
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
