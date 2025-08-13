# app/routers/admin_terms.py

from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.schemas.term import TermDetail
from app.schemas.term_admin import TermCreate, TermUpdate, TermOut
from app.services import term_service
from app.core.auth import require_admin

router = APIRouter(
    prefix="/admin/terms",
    tags=["admin-terms"],
    dependencies=[Depends(require_admin)],  # 토큰 인증
)

@router.get("/", response_model=List[TermOut])
def list_all_terms(q: str = ""):
    """관리자: 전체 약관 검색/열람 (활성/비활성 포함)"""
    return term_service.search_terms(q=q)

@router.get("/{term_id}", response_model=TermDetail)
def get_admin_term_detail(term_id: int):
    # 관리자 상세는 비활성도 조회 가능하게 하려면 is_active 필터 제거된 전용 함수 만들어도 됨
    term = term_service.get_term_by_id(term_id)  # public 필터(활성만) 쓰면 비활성은 못 봄
    if not term:  # 필요하면 admin용 get_admin_term_by_id 구현해서 is_active 무시 가능
        raise HTTPException(status_code=404, detail="해당 ID의 약관을 찾을 수 없습니다.")
    return term

@router.post("/", response_model=dict, status_code=201)
def create_term(payload: TermCreate):
    new_id = term_service.create_term(payload)
    return {"id": new_id}

@router.put("/{term_id}", response_model=dict)
def update_term(term_id: int, payload: TermUpdate):
    ok = term_service.update_term(term_id, payload)
    if not ok:
        raise HTTPException(status_code=404, detail="해당 ID의 약관을 찾을 수 없습니다.")
    return {"updated": True}

@router.delete("/{term_id}", response_model=dict)
def delete_term(term_id: int):
    ok = term_service.delete_term(term_id)
    if not ok:
        raise HTTPException(status_code=404, detail="해당 ID의 약관을 찾을 수 없습니다.")
    return {"deleted": True}
