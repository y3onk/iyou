# app/routers/public_terms.py

from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas.term import TermInList, TermDetail, TermSummary
from app.services import term_service

router = APIRouter(
    prefix="/public/terms",
    tags=["public-terms"],
)

@router.get("/", response_model=List[TermInList])
def read_terms_list():
    """활성화된 약관의 목록(요약용 메타)"""
    # 필요 시 서비스에서 is_active=1 필터 적용
    return term_service.get_all_terms(only_active=True)

@router.get("/{term_id}", response_model=TermDetail)
def read_term_detail(term_id: int):
    """특정 약관 전문 (public: 활성 항목만)"""
    term = term_service.get_term_by_id(term_id, only_active=True)
    if not term:
        raise HTTPException(status_code=404, detail="해당 ID의 약관을 찾을 수 없습니다.")
    return term

@router.get("/{term_id}/summary", response_model=TermSummary)
def read_term_summary(term_id: int):
    """특정 약관의 AI 요약본 (public: 활성 항목만)"""
    summary = term_service.get_term_summary_by_id(term_id)
    if summary is None:
        raise HTTPException(status_code=404, detail="해당 ID의 약관을 찾을 수 없습니다.")
    return summary
