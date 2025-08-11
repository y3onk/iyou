# app/services/term_service.py

# 임시 약관 데이터베이스 (딕셔너리)
fake_terms_db = {
    1: {"id": 1, "title": "서비스 이용약관", "content": "제 1조 (목적) 이 약관은 사용자의 행복을 최우선으로 합니다..."},
    2: {"id": 2, "title": "개인정보 처리방침", "content": "제 1조 (개인정보) 사용자의 개인정보는 소중하게 다뤄집니다..."}
}

def get_all_terms():
    # DB에서 제목과 ID만 추출하여 반환
    return [{"id": term["id"], "title": term["title"]} for term in fake_terms_db.values()]

def get_term_by_id(term_id: int):
    return fake_terms_db.get(term_id)

def get_term_summary_by_id(term_id: int):
    term = fake_terms_db.get(term_id)
    if not term:
        return None
    
    # TODO: 실제 AI 요약 모델 호출 로직 구현
    # 여기서는 간단한 문자열 조작으로 요약 흉내
    summary_text = f"이것은 '{term['title']}'의 AI 요약본입니다. 사용자의 권리와 서비스의 목적을 명확히 합니다."
    
    return {"id": term["id"], "title": f"{term['title']} (요약)", "summary": summary_text}