# app/main.py
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from app.routers import terms

app = FastAPI(
    title="프로토타입 서버",
    description="사용자 가입 및 약관 요약 API",
    version="0.1.0",
)
origins = [
    "http://localhost:8080",
    "http://localhost",
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 포함
app.include_router(terms.router)

@app.get("/")
def read_root():
    return {"message": "API 서버가 실행 중입니다. /docs 에서 API 문서를 확인하세요."}