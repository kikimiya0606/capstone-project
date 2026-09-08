from pydantic import BaseModel, Field, field_validator
from typing import Literal, Annotated


class MoodAnalysisRequest(BaseModel):
    mood_text: str = Field(..., min_length=1, description="사용자가 작성한 한 줄 감정 기록")
    mood_tag: str = Field(..., min_length=1, description="사용자가 직접 선택한 기분 태그")
    user_role: str = Field(..., min_length=1, description="작성자의 가족 내 역할 (예: 딸, 아빠)")
    family_roles: list[str] = Field(
        default_factory=list,
        description="작성자를 제외한 나머지 가족 구성원 역할 목록",
    )


class MoodAnalysisResponse(BaseModel):
    ai_emotion: str
    self_message: str
    family_message: str
    family_roles: list[str]


class PetPhotoAnalysisResponse(BaseModel):
    breed: str
    color_description: str


class PetChatTurn(BaseModel):
    role: Literal['user', 'model']
    text: str = Field(min_length=1, max_length=4000)


class PetChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=500, pattern=r'\S')
    care_context: str = Field(default='', max_length=2000)
    history: list[PetChatTurn] = Field(default_factory=list, max_length=12)
    pet_name: str = Field(default='', max_length=80)
    personality_answers: list[Annotated[int, Field(strict=True, ge=0, le=2)]] = Field(default_factory=list, max_length=4)

    @field_validator('personality_answers')
    @classmethod
    def valid_answers(cls, answers):
        if len(answers) not in (0, 4):
            raise ValueError('Answer all four questions')
        return answers


class PetChatResponse(BaseModel):
    reply: str


class InsightChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=1000, pattern=r'\S')
    family_context: str = Field(default='', max_length=16000)
    history: list[PetChatTurn] = Field(default_factory=list, max_length=12)


class FamilySignalRequest(BaseModel):
    family_context: str = Field(default='', max_length=16000)
    interaction_summary: str = Field(default='', max_length=4000)
