# app/models/term_summary.py
from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
from app.db.base import Base

class TermSummary(Base):
    __tablename__ = "term_summaries"

    id = Column(Integer, primary_key=True)
    term_id = Column(Integer, ForeignKey("terms.id", ondelete="CASCADE"), index=True, nullable=False)

    revision_version = Column(String(50), nullable=True, index=True)
    summary_text = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    keywords = Column(Text, nullable=True)

    term = relationship("Term", backref="summaries")

    # 유니크 키
    __table_args__ = (
        UniqueConstraint("term_id", "revision_version", name="uq_term_rev"),
    )

