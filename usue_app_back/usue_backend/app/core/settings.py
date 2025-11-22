import os
from pathlib import Path

from dotenv import load_dotenv
from pydantic import BaseModel
from pydantic_settings import BaseSettings

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent.parent


class AuthJWT(BaseModel):
    private_key_path: Path = BASE_DIR / "certs" / "jwt_private.pem"
    public_key_path: Path = BASE_DIR / "certs" / "jwt_public.pem"
    algorithm: str = "RS256"
    access_token_expire_minutes: int = 15


class Settings(BaseSettings):
    db_url: str = os.getenv(
        "DB_URL",
        f"sqlite+aiosqlite:///{(BASE_DIR / 'usue_shop.db').as_posix()}",
    )
    db_echo: bool = os.getenv("DB_ECHO", "false").lower() == "true"
    auth_jwt: AuthJWT = AuthJWT()


settings = Settings()
