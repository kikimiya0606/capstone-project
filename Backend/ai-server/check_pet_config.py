"""Check configured Gemini model without printing credentials."""
from app.config import get_settings
from app.gemini_service import get_client
from google.genai import errors
import sys
import time
from app.gemini_service import generate_pet_reply

settings = get_settings()
try:
    model = get_client().models.get(model=settings.gemini_model)
    print('Configured model accessible:', model.name)
    if '--chat' in sys.argv:
        started = time.monotonic()
        reply = generate_pet_reply('안녕! 누구 기다리고 있어?', '아빠: 밥 주기 / 미완료', [])
        print('Reply seconds:', round(time.monotonic() - started, 1))
        print('Reply:', reply)
except errors.APIError as error:
    message = str(error.message or '').replace(settings.gemini_api_key or 'NO_KEY', '[REDACTED]')
    print('Provider status:', error.code)
    print('Provider message:', message[:600])
