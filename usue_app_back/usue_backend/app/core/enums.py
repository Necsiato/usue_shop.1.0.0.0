from enum import Enum


class UserRole(str, Enum):
    ADMIN = "admin"
    CUSTOMER = "user"


class OrderStatus(str, Enum):
    NEW = "new"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELED = "canceled"
