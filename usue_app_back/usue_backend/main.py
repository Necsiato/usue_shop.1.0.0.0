import uvicorn
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.db.database import db
from app.db.seed import seed_database
from app.ecommerce.router import shop_router


app = FastAPI(title="USUE Shop API", version="0.1.0")

app.include_router(shop_router, prefix="/api/v1")

ALLOWED_ORIGINS = [
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    "http://192.168.0.169:8080",
    "http://localhost:8085",
    "http://127.0.0.1:8085",
    "http://192.168.0.169:8085",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

STATIC_DIR = Path(__file__).resolve().parent / "app" / "static"
STATIC_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

@app.on_event("startup")
async def on_startup() -> None:
    await db.init_models()
    await seed_database()


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8090,
        reload=True,
        proxy_headers=True,
        forwarded_allow_ips="*",
    )
