from __future__ import annotations

from typing import Dict, List

from sqlalchemy import Float, ForeignKey, JSON, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base


class Product(Base):
    __tablename__ = "products"

    id: Mapped[str] = mapped_column(String(80), primary_key=True)
    category_id: Mapped[int] = mapped_column(ForeignKey("categories.id"))
    title: Mapped[str] = mapped_column(String(160))
    description: Mapped[str] = mapped_column(Text)
    price: Mapped[float] = mapped_column(Float)
    image_urls: Mapped[List[str]] = mapped_column(JSON, default=list)
    characteristics: Mapped[Dict[str, str]] = mapped_column(JSON, default=dict)

    category = relationship("Category", back_populates="products")
