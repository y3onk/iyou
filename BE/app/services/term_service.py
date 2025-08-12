# app/services/term_service.py
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.term import Term
from app.models.term_summary import TermSummary

# (선택) 첫 실행 편의를 위한 시드
_FAKE = {
    1: {"id": 1, "title": "서비스 이용약관", "content": "제1조(목적) ..."},
    2: {"id": 2, "title": "개인정보 처리방침", "content": "제1조(개인정보) ..."},
}

_PROVIDER_NAME = "fake-provider"
_PROVIDER_VER  = "0.0.1"

def _seed_if_empty(db: Session):
    if db.query(Term).count() == 0:
        for t in _FAKE.values():
            db.add(Term(id=t["id"], title=t["title"], content=t["content"]))
        db.commit()

def get_all_terms():
    with SessionLocal() as db:
        _seed_if_empty(db)
        rows = db.query(Term.id, Term.title).all()
        return [{"id": r[0], "title": r[1]} for r in rows]

def get_term_by_id(term_id: int):
    with SessionLocal() as db:
        _seed_if_empty(db)
        row = db.query(Term).filter(Term.id == term_id).first()
        if not row:
            return None
        return {"id": row.id, "title": row.title, "content": row.content}

def _fake_summarize(title: str) -> str:
    # 실제 모델 준비 전까지 임시 요약
    return f"이것은 '{title}'의 AI 요약본입니다. 사용자의 권리와 서비스의 목적을 명확히 합니다."

def get_term_summary_by_id(term_id: int):
    with SessionLocal() as db:
        _seed_if_empty(db)

        term = db.query(Term).filter(Term.id == term_id).first()
        if not term:
            return None

        # 1) 캐시 조회 (동일 모델/버전)
        cached = (
            db.query(TermSummary)
            .filter(
                TermSummary.term_id == term_id,
                TermSummary.model_name == _PROVIDER_NAME,
                TermSummary.model_version == _PROVIDER_VER,
            )
            .order_by(TermSummary.created_at.desc())
            .first()
        )
        if cached:
            return {
                "id": term.id,
                "title": f"{term.title} (요약)",
                "summary": cached.summary_text or "",
            }

        # 2) 캐시 미스 → 요약 생성
        summary_text = _fake_summarize(term.title)

        # 3) 저장
        row = TermSummary(
            term_id=term.id,
            model_name=_PROVIDER_NAME,
            model_version=_PROVIDER_VER,
            summary_text=summary_text,
        )
        db.add(row)
        db.commit()
        db.refresh(row)

        # 4) 응답
        return {
            "id": term.id,
            "title": f"{term.title} (요약)",
            "summary": summary_text,
        }
