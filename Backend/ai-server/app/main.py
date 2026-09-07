from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from google.genai import errors as genai_errors

from . import gemini_service
from .config import get_settings
from .emotion_model import get_classifier
from .schemas import MoodAnalysisRequest, MoodAnalysisResponse, PetPhotoAnalysisResponse
from .schemas import PetChatRequest, PetChatResponse
from .schemas import InsightChatRequest
from . import ollama_service
import httpx

app = FastAPI(title="AI Family Emotion Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=get_settings().cors_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post('/pet-chat', response_model=PetChatResponse)
def pet_chat(req: PetChatRequest) -> PetChatResponse:
    if not get_settings().gemini_api_key:
        raise HTTPException(status_code=503, detail='AI 대화가 아직 설정되지 않았어요.')
    try:
        reply = gemini_service.generate_pet_reply(req.message, req.care_context, req.history,
                                                  req.pet_name, req.personality_answers)
    except genai_errors.APIError as exc:
        code = 429 if exc.code == 429 else 502
        raise HTTPException(status_code=code, detail='잠시 후 다시 말 걸어주세요.') from exc
    except (ValueError, TimeoutError) as exc:
        raise HTTPException(status_code=502, detail='답변을 받지 못했어요. 다시 시도해주세요.') from exc
    return PetChatResponse(reply=reply)


@app.post('/insight-chat', response_model=PetChatResponse)
async def insight_chat(req: InsightChatRequest) -> PetChatResponse:
    try:
        return PetChatResponse(reply=await ollama_service.chat(req.message, req.family_context, req.history))
    except httpx.TimeoutException as exc:
        raise HTTPException(status_code=504, detail='답변 준비가 오래 걸려요. 잠시 후 다시 보내주세요.') from exc
    except httpx.ConnectError as exc:
        raise HTTPException(status_code=503, detail='인사이트 대화 서버가 아직 준비되지 않았어요.') from exc
    except httpx.HTTPStatusError as exc:
        raise HTTPException(status_code=502, detail='인사이트 모델 설정을 확인해주세요.') from exc
    except (ValueError, httpx.RequestError) as exc:
        raise HTTPException(status_code=502, detail='인사이트 답변을 받지 못했어요.') from exc


@app.post("/analyze-mood", response_model=MoodAnalysisResponse)
def analyze_mood(req: MoodAnalysisRequest) -> MoodAnalysisResponse:
    ai_emotion = get_classifier().predict(req.mood_text)

    try:
        self_message = gemini_service.generate_self_message(
            req.mood_text, req.user_role, req.mood_tag, ai_emotion
        )
        family_message = gemini_service.generate_family_message(
            req.mood_text, req.user_role, req.mood_tag, ai_emotion
        )
    except genai_errors.APIError as exc:
        if exc.code == 429:
            raise HTTPException(status_code=429, detail="Gemini API rate limited") from exc
        raise HTTPException(status_code=502, detail=f"Gemini API error: {exc.message}") from exc

    return MoodAnalysisResponse(
        ai_emotion=ai_emotion,
        self_message=self_message,
        family_message=family_message,
        family_roles=req.family_roles,
    )


@app.post("/analyze-pet-photo", response_model=PetPhotoAnalysisResponse)
async def analyze_pet_photo(images: list[UploadFile] = File(...)) -> PetPhotoAnalysisResponse:
    if not images:
        raise HTTPException(status_code=422, detail="사진을 1장 이상 첨부해주세요.")
    if len(images) > 5:
        raise HTTPException(status_code=422, detail="사진은 최대 5장까지 가능해요.")

    image_bytes = [await image.read() for image in images]

    try:
        result = gemini_service.analyze_pet_photos(image_bytes)
    except genai_errors.APIError as exc:
        if exc.code == 429:
            raise HTTPException(status_code=429, detail="Gemini API rate limited") from exc
        raise HTTPException(status_code=502, detail=f"Gemini API error: {exc.message}") from exc

    return PetPhotoAnalysisResponse(
        breed=result["breed"],
        color_description=result["color_description"],
    )
