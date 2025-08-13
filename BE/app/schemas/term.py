# app/schemas/term.py

from typing import Optional, List
from pydantic import BaseModel

class TermInList(BaseModel):
    id: int
    title: str

class TermDetail(BaseModel):
    id: int
    title: str
    content: str

class TermSummary(BaseModel):
    id: int
    title: str
    summary: str
    revision_version: Optional[str] = None
    keywords: Optional[List[str]] = None