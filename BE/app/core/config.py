# app/core/config.py
import os
from dotenv import load_dotenv

# BE/.env 로드
# uvicorn을 BE 폴더에서 실행한다면 아래로 충분.
# 만약 다른 경로에서 실행한다면 load_dotenv(dotenv_path=...)로 절대경로 지정 가능.
load_dotenv()

def _get_bool(key: str, default: bool = False) -> bool:
    v = os.getenv(key)
    if v is None:
        return default
    return v.lower() in ("1", "true", "yes", "y")

DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./term.db")
DEBUG: bool = _get_bool("DEBUG", True)

# CORS_ORIGINS가 * 이면 전체 허용, 아니면 콤마로 구분된 리스트
_raw_origins = os.getenv("CORS_ORIGINS", "*")
if _raw_origins.strip() == "*":
    CORS_ALLOW_ALL = True
    CORS_ORIGINS = ["*"]
else:
    CORS_ALLOW_ALL = False
    CORS_ORIGINS = [o.strip() for o in _raw_origins.split(",") if o.strip()]
