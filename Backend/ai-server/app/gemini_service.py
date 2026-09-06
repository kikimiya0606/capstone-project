from google import genai

from .config import get_settings

_client: genai.Client | None = None


def get_client() -> genai.Client:
    global _client
    if _client is None:
        _client = genai.Client(api_key=get_settings().gemini_api_key)
    return _client


def _ask(prompt: str) -> str:
    settings = get_settings()
    response = get_client().models.generate_content(
        model=settings.gemini_model,
        contents=prompt,
    )
    return response.text.strip()


def generate_self_message(user_text: str, user_role: str, mood_tag: str, ai_emotion: str) -> str:
    prompt = f"""사용자 역할:
{user_role}

사용자가 직접 선택한 기분:
{mood_tag}

사용자 한 줄 기록:
{user_text}

AI 감정 분석 결과:
{ai_emotion}

사용자 본인에게 보여줄 팝업 메시지를 작성해줘.

조건
- 반드시 1문장
- 30자 이내
- 사용자가 선택한 기분 "{mood_tag}"을 중심으로 공감
- 따뜻한 공감 중심
- 조언 금지
- 이모지 사용 금지"""
    return _ask(prompt)


def generate_family_message(user_text: str, user_role: str, mood_tag: str, ai_emotion: str) -> str:
    prompt = f"""사용자 역할:
{user_role}

사용자가 직접 선택한 기분:
{mood_tag}

사용자 한 줄 기록:
{user_text}

AI 감정 분석 결과:
{ai_emotion}

가족 구성원에게 보여줄 팝업 알림을 작성해줘.

조건
- 한 문장
- 40자 이내
- "{user_role}" 역할을 자연스럽게 포함
- 일기 원문 그대로 공개 금지
- 감정명 직접 언급 금지
- 사용자가 어떤 상황인지 짧게 요약
- 가족이 건넬 수 있는 자연스러운 말 또는 행동 제안
- 상담사 말투 금지
- 이모지 사용 금지"""
    return _ask(prompt)
