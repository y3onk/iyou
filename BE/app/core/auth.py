import os
from fastapi import Header, HTTPException

ADMIN_TOKEN = os.getenv("ADMIN_TOKEN", "")  # .env에 저장된 관리자 토큰

def require_admin(authorization: str = Header(default="")):
    """
    Authorization: Bearer <TOKEN>
    """
    try:
        scheme, token = authorization.split(" ", 1)
    except ValueError:
        raise HTTPException(status_code=401, detail="Unauthorized")

    if scheme.lower() != "bearer" or token != ADMIN_TOKEN:
        raise HTTPException(status_code=401, detail="Unauthorized")
