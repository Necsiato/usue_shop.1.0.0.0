from dataclasses import dataclass, field
from typing import Dict, List


@dataclass(frozen=True)
class SampleCategory:
    slug: str
    title: str
    description: str
    hero_image: str


@dataclass(frozen=True)
class SampleProduct:
    id: str
    title: str
    description: str
    price: float
    categories: List[str]
    image_urls: List[str]
    characteristics: Dict[str, str] = field(default_factory=dict)


@dataclass(frozen=True)
class _CategorySeed:
    slug: str
    title: str
    description: str
    hero_image: str
    secondary_tags: List[str]
    base_price: float
    price_step: float
    target_count: int


_CATEGORY_SEEDS = [
    _CategorySeed(
        slug="smart-home",
        title="Умный дом",
        description="Датчики, колонки и контроллеры для автоматизации.",
        hero_image="assets/debug/home.png",
        secondary_tags=["гаджеты", "автоматизация", "безопасность"],
        base_price=3490,
        price_step=420,
        target_count=26,
    ),
    _CategorySeed(
        slug="study",
        title="Учёба и офис",
        description="Органайзеры, лампы и аксессуары для продуктивной работы.",
        hero_image="assets/debug/study.png",
        secondary_tags=["канцтовары", "творчество", "аксессуары"],
        base_price=1290,
        price_step=180,
        target_count=24,
    ),
    _CategorySeed(
        slug="travel",
        title="Путешествия",
        description="Рюкзаки, трекеры и портативные гаджеты в дорогу.",
        hero_image="assets/debug/travel.png",
        secondary_tags=["лайфстайл", "аутдор", "безопасность"],
        base_price=5190,
        price_step=560,
        target_count=24,
    ),
    _CategorySeed(
        slug="fitness",
        title="Фитнес и здоровье",
        description="Баланc-борды, бутылки и трекеры для ежедневных тренировок.",
        hero_image="assets/debug/fitness.png",
        secondary_tags=["wellness", "автоматизация", "аутдор"],
        base_price=2890,
        price_step=260,
        target_count=24,
    ),
    _CategorySeed(
        slug="coffee",
        title="Кофе и кухня",
        description="Воронки, кофемолки и дегустационные наборы для любителей кофе.",
        hero_image="assets/debug/coffee.png",
        secondary_tags=["кухня", "подарки", "лайфстайл"],
        base_price=1890,
        price_step=210,
        target_count=24,
    ),
]

SAMPLE_CATEGORIES = [
    SampleCategory(
        slug=seed.slug,
        title=seed.title,
        description=seed.description,
        hero_image=seed.hero_image,
    )
    for seed in _CATEGORY_SEEDS
]


def _generate_products() -> List[SampleProduct]:
    adjectives = ["Пульс", "Поток", "Нео", "Эдж", "Флекс", "Сенс", "Прайм", "Эйр", "Нова", "Спарк"]
    finishes = ["Графит", "Арктик", "Роуз", "Индиго", "Янтарь"]
    products: List[SampleProduct] = []

    for seed in _CATEGORY_SEEDS:
        for index in range(seed.target_count):
            adjective = adjectives[(index + len(seed.slug)) % len(adjectives)]
            finish = finishes[index % len(finishes)]
            price = seed.base_price + seed.price_step * (index % 5)
            categories = {seed.slug, seed.secondary_tags[index % len(seed.secondary_tags)]}
            if index % 6 == 0:
                categories.add("limited")
            product_id = f"{seed.slug}-{index + 1}"
            characteristics = {
                "Материал": finish,
                "Питание": "USB-C" if index % 2 == 0 else "Батарея",
                "Гарантия": f"{12 + (index % 4) * 6} месяцев",
            }

            products.append(
                SampleProduct(
                    id=product_id,
                    title=f"{seed.title.split()[0]} {adjective} {finish}",
                    description=f"{seed.description} Модель #{index + 1} с расширенной комплектацией.",
                    price=price,
                    categories=list(categories),
                    image_urls=[seed.hero_image],
                    characteristics=characteristics,
                )
            )

    return products


SAMPLE_PRODUCTS = _generate_products()
