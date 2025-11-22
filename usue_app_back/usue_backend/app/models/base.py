from datetime import datetime
from typing import Optional

from sqlalchemy import Boolean, DateTime, String, func
from sqlalchemy.orm import DeclarativeBase, Mapped, declared_attr, mapped_column


class Base(DeclarativeBase):
    """Базовый класс для всех ORM-моделей."""

    @declared_attr.directive
    def __tablename__(cls) -> str:  # pragma: no cover - простая утилита
        return f"{cls.__name__.lower()}s"

    created: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        comment="Дата создания записи",
    )
    updated: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        server_onupdate=func.now(),
        comment="Дата последнего обновления",
    )
    is_deleted: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        comment="Флаг мягкого удаления",
    )


class AuditBase(Base):
    """Расширение Base с полями аудита."""

    __abstract__ = True

    created_by: Mapped[str] = mapped_column(
        String(64),
        comment="Идентификатор автора записи",
    )
    updated_by: Mapped[Optional[str]] = mapped_column(
        String(64),
        nullable=True,
        comment="Идентификатор последнего редактора",
    )
