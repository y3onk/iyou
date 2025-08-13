from pydantic import BaseModel
from typing import Optional

class TermCreate(BaseModel):
    title: str
    content: str
    version: Optional[str] = "v1.0"
    effective_date: Optional[str] = None  # 'YYYY-MM-DD'
    is_active: Optional[int] = 1

class TermUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    version: Optional[str] = None
    effective_date: Optional[str] = None
    is_active: Optional[int] = None

class TermOut(BaseModel):
    id: int
    title: str
    version: Optional[str]
    effective_date: Optional[str]
    is_active: int
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
