from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google.genai import errors as genai_errors

from . import gemini_service
from .config import get_settings
from .emotion_model import get_classifier
from .schemas import MoodAnalysisRequest, MoodAnalysisResponse

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
