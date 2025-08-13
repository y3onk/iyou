# app/services/term_service.py
from typing import List, Dict, Any, Optional
import re
from sqlalchemy.orm import Session
from sqlalchemy import or_
from app.db.session import SessionLocal
from app.models.term import Term
from app.models.term_summary import TermSummary

# 첫 실행 편의를 위한 시드
_FAKE = {
    1: {"id": 1, "title": "서비스 이용약관", "content": "제1조(목적) 목적 내용...\n제2조(용어의 정의) 정의 내용...\n제3조(계약의 성립) 성립 내용...\n"},
    2: {"id": 2, "title": "개인정보 처리방침", "content": "제1조(개인정보) ..."},
}


def _seed_if_empty(db: Session):
    if db.query(Term).count() == 0:
        for t in _FAKE.values():
            db.add(Term(id=t["id"], title=t["title"], content=t["content"]))
        db.commit()

# -----------------------
# Public: 목록(제목만), 상세, 요약
# -----------------------
def get_all_terms(only_active: bool = True) -> List[Dict[str, Any]]:
    with SessionLocal() as db:
        _seed_if_empty(db)
        if only_active and hasattr(Term, "is_active"):
            q = q.filter(Term.is_active == 1)
        rows = db.query(Term.id, Term.title).order_by(Term.id.desc()).all()
        return [{"id": r[0], "title": r[1]} for r in rows]

def get_term_by_id(term_id: int, only_active: bool = True) -> Optional[Dict[str, Any]]:
    with SessionLocal() as db:
        _seed_if_empty(db)
        q= db.query(Term).filter(Term.id == term_id)
        if only_active and hasattr(Term, "is_active"):
            q = q.filter(Term.is_active == 1)
        row = q.first()
        if not row:
            return None
        return {"id": row.id, "title": row.title, "content": row.content}


def get_term_summary_by_id(term_id: int) -> Optional[Dict[str, Any]]:
    print("### THIS FUNCTION IS RUNNING ###")

    """
    term_summaries에서 이미 생성된 요약만 조회한다.
    - Term.revision_version이 있으면 해당 버전으로 필터
    - 없으면 term_id 기준 최신(created_at DESC) 1건
    - 없으면 None 반환 (라우터에서 404 처리)
    """
    with SessionLocal() as db:
        _seed_if_empty(db)

        term = db.query(Term).filter(Term.id == term_id).first()
        if not term:
            return None

        # Term에 revision_version 필드가 있으면 그 값으로 요약 선택
        rev = getattr(term, "revision_version", None)

        q = db.query(TermSummary).filter(TermSummary.term_id == term_id)
        if rev is not None:
            q = q.filter(TermSummary.revision_version == rev)

        row = q.order_by(TermSummary.created_at.desc()).first()
        if row is None:
            return None
        
        # keywords 문자열 → 리스트 변환
        raw_keywords = (getattr(row, "keywords", "") or "").strip()
        keywords_list = [
            k.strip() for k in re.split(r"[,\n;/|、，·•]", raw_keywords) if k.strip()
        ]

        print("KW from DB:", row.keywords)
        return {
            "id": term.id,
            "title": f"{term.title} (요약)",
            "summary": row.summary_text or "",
            "revision_version": getattr(row, "revision_version", None),
            "keywords": keywords_list,
        }
    
# -----------------------
# Admin: 검색/목록, 생성, 수정, 삭제
# -----------------------
def search_terms(q: str = "") -> List[Dict[str, Any]]:
    """
    관리자 목록: 현재 스키마(id, title, content)에 맞춘 최소 구현.
    - q가 있으면 title/content LIKE 검색
    - content는 미리보기 일부만 잘라서 반환
    """
    with SessionLocal() as db:
        _seed_if_empty(db)
        query = db.query(Term).order_by(Term.id.desc())
        if q:
            like = f"%{q}%"
            query = query.filter(or_(Term.title.like(like), Term.content.like(like)))
        rows = query.all()
        out: List[Dict[str, Any]] = []
        for r in rows:
            preview = (r.content or "")
            if len(preview) > 200:
                preview = preview[:200] + "…"
            out.append({
                "id": r.id,
                "title": r.title,
                # 아래 필드는 UI 호환용 자리 채움(모델에 컬럼 없으므로 None/기본값)
                "version": None,
                "effective_date": None,
                "is_active": 1,  # 임시로 항상 활성 처리
                "content": preview,
            })
        return out

def create_term(payload: Dict[str, Any]) -> int:
    """
    관리자 생성: 최소 구현(title, content만 사용)
    payload 예: {"title": "...", "content": "...", (기타 필드는 무시)}
    """
    title = (payload.get("title") or "").strip()
    content = (payload.get("content") or "").strip()
    if not title:
        raise ValueError("title is required")
    with SessionLocal() as db:
        row = Term(title=title, content=content)
        db.add(row)
        db.commit()
        db.refresh(row)
        return row.id

def update_term(term_id: int, payload: Dict[str, Any]) -> bool:
    """
    관리자 수정: title/content/is_active(옵션) 업데이트 (존재 안 하면 False)
    """
    with SessionLocal() as db:
        row = db.query(Term).filter(Term.id == term_id).first()
        if not row:
            return False

        # 제목/본문
        if "title" in payload and payload["title"] is not None:
            row.title = str(payload["title"])
        if "content" in payload and payload["content"] is not None:
            row.content = str(payload["content"])

        # 소프트 삭제/복구 지원
        if "is_active" in payload and payload["is_active"] is not None:
            # 정수/불리언 섞여 들어와도 안전하게 처리
            v = payload["is_active"]
            row.is_active = int(v) if isinstance(v, (bool, int)) else int(str(v))

        db.add(row)
        db.commit()
        return True

def soft_delete_term(term_id: int) -> bool:
    return update_term(term_id, {"is_active": 0})

def restore_term(term_id: int) -> bool:
    return update_term(term_id, {"is_active": 1})
