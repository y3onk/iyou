# app/models/term.py
from sqlalchemy import Column, Integer, String, Text
from app.db.base import Base

class Term(Base):
    __tablename__ = "terms"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    content = Column(Text, nullable=False)
    summary = Column(Text)
    is_active = Column(Integer, nullable=False, default=1)  # 1=활성, 0=삭제(비활성) soft-delete 처리
