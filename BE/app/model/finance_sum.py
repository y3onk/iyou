# batch_process_summaries.py (ID별 처리 기능 추가 최종 버전)

import os
import torch
import torch.nn as nn
import torch.nn.functional as F
import kss
import sqlite3
from transformers import BertModel
from kobert_tokenizer import KoBERTTokenizer
from konlpy.tag import Okt # Mecab 대신 Okt 사용
from collections import Counter
from openai import OpenAI
from tqdm import tqdm
import logging
import argparse # [추가] 커맨드 라인 인자 처리를 위한 라이브러리
from dotenv import load_dotenv
import json
#load_dotenv()

# --- 기본 로깅 설정 ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# --- 설정 (Configuration) ---
BASE_MODEL_NAME = "skt/kobert-base-v1"

# (이전과 동일한 클래스 및 함수 정의는 생략)
# ... BERTClassifier, BERTSumDataset, extract_key_sentences, extract_keywords, generate_gpt_summary ...
class BERTClassifier(nn.Module):
    def __init__(self, bert, hidden_size=768, num_classes=2, dr_rate=None):
        super().__init__()
        self.bert = bert
        self.classifier = nn.Linear(hidden_size, num_classes)
        self.dr_rate = dr_rate
        if dr_rate:
            self.dropout = nn.Dropout(p=dr_rate)

    def forward(self, input_ids, attention_mask, token_type_ids=None):
        _, pooler_output = self.bert(input_ids=input_ids,
                                 attention_mask=attention_mask,
                                 token_type_ids=token_type_ids)
        out = self.dropout(pooler_output) if self.dr_rate and self.training else pooler_output
        return self.classifier(out)


def extract_key_sentences(text: str, model: BERTClassifier, tokenizer, device, top_n: int = 3) -> list[str]:
    with torch.no_grad():
        sentences = kss.split_sentences(text)
        if not sentences: return []
        inputs = tokenizer(sentences, padding=True, truncation=True, return_tensors="pt", max_length=128).to(device)
        outputs = model(**inputs); probs = F.softmax(outputs, dim=1); core_probs = probs[:, 1].cpu().numpy()
        sorted_indices = core_probs.argsort()[::-1]
        return [sentences[idx] for idx in sorted_indices[:top_n]]
def extract_keywords(sentences_list: list[str], tagger) -> list[str]:
    full_text = " ".join(sentences_list); nouns = tagger.nouns(full_text)
    meaningful_nouns = [n for n in nouns if len(n) > 1]
    if not meaningful_nouns: return []
    return list(Counter(meaningful_nouns).keys())

def extract_keywords(sentences_list: list[str], tagger) -> list[str]:
    full_text = " ".join(sentences_list)
    nouns = tagger.nouns(full_text)
    meaningful_nouns = [n for n in nouns if len(n) > 1]
    return list(Counter(meaningful_nouns).keys())

# --- GPT 요약 생성 ---
def generate_gpt_summary(key_sentences: list[str], raw_keywords: list[str], client: OpenAI) -> str:
    if not key_sentences: return ""
    prompt = f"""# 지시사항
당신은 금융 및 법률 약관을 분석하고 요약하는 최고 수준의 AI 전문가입니다.
1차 AI가 추출한 '핵심 문장'과 '초벌 키워드'가 주어집니다.
당신의 임무는 다음 두 가지를 **JSON 형식**으로 출력하는 것입니다.

1.  **`refined_keywords`**: '핵심 문장'의 문맥을 깊이 이해하여, '초벌 키워드' 중에서 정말로 중요하고 의미 있는 단어만 필터링한 키워드 리스트. 불필요하거나, 형태소가 이상하거나, 중요하지 않은 단어는 반드시 제거해야 합니다.
2.  **`summary_text`**: '핵심 문장'의 내용만을 기반으로 하고, 당신이 방금 정제한 `refined_keywords`를 자연스럽게 포함하여, 최종 사용자가 이해하기 쉬운 3문장 이내의 완결된 요약문.

# 제약 조건
- `summary_text`는 '핵심 문장'에 없는 내용을 절대 추가해서는 안 됩니다.
- 원문의 전문적인 어휘와 의미를 최대한 유지해야 합니다.
- 최종 출력은 반드시 아래와 같은 JSON 형식이어야 합니다.

# 입력 데이터
## 핵심 문장
{'- ' + '\n- '.join(key_sentences)}

## 초벌 키워드
{', '.join(raw_keywords)}

# 출력 (JSON 형식):
"""
    try:
        completion = client.chat.completions.create(
            model="gpt-4o",
            response_format={"type": "json_object"}, # JSON 출력 모드 사용
            messages=[{"role": "user", "content": prompt}]
        )
        result_json = json.loads(completion.choices[0].message.content)
        
        refined_keywords = result_json.get("refined_keywords", raw_keywords)
        summary_text = result_json.get("summary_text", " ".join(key_sentences))
        
        return summary_text, refined_keywords

    except Exception as e:
        logging.error(f"GPT API 호출 또는 JSON 파싱 오류: {e}")
        # 오류 발생 시, 정제 없이 기존 결과 반환
        return " ".join(key_sentences), raw_keywords
        
        
    
# --- [수정됨] DB 연동 함수 ---
def get_all_terms(DB_PATH: str):
    """ DB에서 '모든' 약관을 불러오는 함수 """
    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        cur.execute("SELECT id, title, content FROM terms")
        return cur.fetchall()

def get_terms_by_ids(DB_PATH: str, term_ids: list[int]):
    """ [추가됨] DB에서 '지정된 ID'의 약관들만 불러오는 함수 """
    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        # SQL의 IN 연산자를 사용하여 여러 ID를 한 번에 조회
        placeholders = ','.join('?' for _ in term_ids)
        query = f"SELECT id, title, content FROM terms WHERE id IN ({placeholders})"
        cur.execute(query, term_ids)
        return cur.fetchall()

def save_summary_to_db(DB_PATH: str, term_id: int, summary_text: str, keywords: list[str]):
    """
    term_summaries 테이블에 요약 저장
    revision_version은 동일 term_id 내에서 존재하는 버전을 기준으로 자동 생성
    """
    keywords_str = ','.join(keywords)

    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        # 테이블 생성 (없으면)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS term_summaries (
                id               INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT,
                term_id          INTEGER      NOT NULL REFERENCES terms (id) ON DELETE CASCADE,
                revision_version VARCHAR(50)  NOT NULL,
                summary_text     TEXT,
                created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                keywords         TEXT,
                CONSTRAINT uq_term_revision UNIQUE(term_id, revision_version)
            )
        """)
        cur.execute("CREATE INDEX IF NOT EXISTS ix_term_summaries_term_id ON term_summaries (term_id)")

        # 기존 revision_version 조회
        cur.execute("""
            SELECT revision_version
            FROM term_summaries
            WHERE term_id = ?
        """, (term_id,))
        existing_versions = cur.fetchall()  # [('v1',), ('v2',), ...]

        # 다음 버전 계산
        if not existing_versions:
            next_version = 1
        else:
            # 'v숫자' 형태에서 숫자만 뽑아 최대값 + 1
            max_v = max(int(v[0].lstrip('v')) for v in existing_versions)
            next_version = max_v + 1

        revision_version = f"v{next_version}"

        # 데이터 삽입
        cur.execute("""
            INSERT INTO term_summaries (term_id, revision_version, summary_text, keywords)
            VALUES (?, ?, ?, ?)
        """, (term_id, revision_version, summary_text, keywords_str))
        conn.commit()
# ========================================================================================
# 4. 메인 실행 로직
# ========================================================================================
if __name__ == "__main__":
    # --- [수정됨] 커맨드 라인 인자 파서 설정 ---
    load_dotenv()
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    PROJECT_ROOT = os.path.dirname(os.path.dirname(SCRIPT_DIR))
    DOTENV_PATH = os.path.join(PROJECT_ROOT, '.env')

    DB_URL = os.getenv("DATABASE_URL", "term.db")  # sqlite:./term.db
    if DB_URL.startswith("sqlite:"):
        DB_PATH = DB_URL.replace("sqlite:", "")      # ./term.db
        DB_PATH = os.path.abspath(os.path.join(PROJECT_ROOT, DB_PATH))
    else:
        DB_PATH = os.path.abspath(DB_URL)

    print("DB_PATH:", DB_PATH)

    MODEL_PATH = os.path.join(SCRIPT_DIR, "kobert_summarization_model.pth")
    
    logging.info(f".env 파일을 로드했습니다.")
    logging.info(f"DB 경로: {DB_PATH}")
    logging.info(f"모델 경로: {MODEL_PATH}")

    # db_url = os.getenv("DATABASE_URL")
    # if not db_url:
    #     raise ValueError(".env 파일에 DATABASE_URL이 설정되지 않았습니다.")
    # DB_PATH = os.path.join(PROJECT_ROOT, db_url) 

    #MODEL_PATH = os.path.join(SCRIPT_DIR, "kobert_summarization_model.pth")

    parser = argparse.ArgumentParser(description="약관 문서를 요약하고 키워드를 추출하여 DB에 저장하는 배치 스크립트")
    parser.add_argument(
        "--ids",
        nargs="+",  # 여러 개의 ID를 받을 수 있도록 설정
        type=int,
        help="처리할 특정 약관 ID 목록. 지정하지 않으면 DB의 모든 약관을 처리합니다."
    )
    args = parser.parse_args()

    # --- 1. AI 모델 및 리소스 로드 ---
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    logging.info(f"Using device: {device}")
    
    try:
        tokenizer = KoBERTTokenizer.from_pretrained(BASE_MODEL_NAME)
        bertmodel = BertModel.from_pretrained(BASE_MODEL_NAME, return_dict=False)
        summarization_model = BERTClassifier(bertmodel, num_classes=2, dr_rate=0.5).to(device)
        summarization_model.load_state_dict(torch.load(MODEL_PATH, map_location=device))
        summarization_model.eval()
        logging.info("✅ 최종 요약 모델 로드 완료.")
    except Exception as e:
        logging.error(f"모델 로딩 중 치명적 오류 발생: {e}")
        exit()
    

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        logging.warning("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다. GPT 요약은 추출 문장 조합으로 대체됩니다.")
    gpt_client = OpenAI(api_key=api_key)
    okt_tagger = Okt()

    # --- [수정됨] 2. 인자에 따라 DB에서 약관 원문 불러오기 ---
    if args.ids:
        # --ids 인자가 주어졌으면, 해당 ID의 약관만 불러오기
        terms_to_process = get_terms_by_ids(DB_PATH, args.ids)
        logging.info(f"지정된 {len(terms_to_process)}개의 약관에 대해 처리를 시작합니다: {args.ids}")
    else:
        # --ids 인자가 없으면, 모든 약관 불러오기
        terms_to_process = get_all_terms(DB_PATH)
        logging.info(f"총 {len(terms_to_process)}개의 모든 약관에 대해 배치 처리를 시작합니다.")

    # --- 3. 배치 처리 실행 ---
    # --- 배치 처리 ---
    if not terms_to_process:
        logging.warning("처리할 약관 데이터가 없습니다.")
    else:
        for term_id, title, content in tqdm(terms_to_process, desc="전체 약관 요약 처리 중"):
            key_sentences = extract_key_sentences(content, summarization_model, tokenizer, device, top_n=3)
            keywords = extract_keywords(key_sentences, okt_tagger)
            final_summary, refined_keywords = generate_gpt_summary(key_sentences, keywords, gpt_client)
            save_summary_to_db(DB_PATH, term_id, final_summary, refined_keywords)

    logging.info("🎉 작업이 성공적으로 완료되었습니다.")