# app/models/term_summary.py
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
from app.db.base import Base

class TermSummary(Base):
    __tablename__ = "term_summaries"

    id = Column(Integer, primary_key=True)
    term_id = Column(Integer, ForeignKey("terms.id", ondelete="CASCADE"), index=True, nullable=False)

    # 모델/버전별로 캐시 구분 (나중에 실제 모델 붙이면 유용)
    model_name = Column(String(100), nullable=False, default="fake-provider")
    model_version = Column(String(50), nullable=False, default="0.0.1")

    # 지금은 단일 요약문만 저장 (향후 bullets/glossary/rights 확장 가능)
    summary_text = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    term = relationship("Term", backref="summaries")

    __table_args__ = (
        UniqueConstraint("term_id", "model_name", "model_version", name="uq_term_model_ver"),
    )
