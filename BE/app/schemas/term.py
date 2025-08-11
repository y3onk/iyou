# app/schemas/term.py

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