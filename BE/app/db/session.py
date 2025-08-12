# app/db/session.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import DATABASE_URL

is_sqlite = DATABASE_URL.startswith("sqlite")

engine_kwargs = {}
if is_sqlite:
    # SQLite 전용 옵션
    engine_kwargs["connect_args"] = {"check_same_thread": False}
else:
    # MySQL/Postgres 등에서만 연결 안정화 옵션 적용
    engine_kwargs["pool_pre_ping"] = True
    engine_kwargs["pool_recycle"] = 3600

engine = create_engine(
    DATABASE_URL,
    **engine_kwargs,
    future=True,  # 선택
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
