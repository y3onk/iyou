# app/routers/terms.py

from fastapi import APIRouter, HTTPException
from typing import List
from app.schemas.term import TermInList, TermDetail, TermSummary
from app.services import term_service

router = APIRouter(
    prefix="/terms",
    tags=["terms"],
)

@router.get("/", response_model=List[TermInList])
def read_terms_list():
    """
    전체 약관 제목 목록 반환
    """
    return term_service.get_all_terms()

@router.get("/{term_id}", response_model=TermDetail)
def read_term_detail(term_id: int):
    """
    특정 약관의 전문 반환
    """
    term = term_service.get_term_by_id(term_id)
    if not term:
        raise HTTPException(status_code=404, detail="해당 ID의 약관을 찾을 수 없습니다.")
    return term

@router.get("/{term_id}/summary", response_model=TermSummary)
def read_term_summary(term_id: int):
    """
    특정 약관의 AI 요약본 반환
    """
    summary = term_service.get_term_summary_by_id(term_id)
    if not summary:
        raise HTTPException(status_code=404, detail="해당 ID의 약관을 찾을 수 없습니다.")
    return summary