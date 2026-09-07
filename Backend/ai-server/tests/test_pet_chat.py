from unittest.mock import patch

from fastapi.testclient import TestClient
from google.genai import errors

from app.main import app

client = TestClient(app)


@patch('app.main.get_settings')
@patch('app.main.gemini_service.generate_pet_reply', return_value='엄마랑 밥 먹고 싶어!')
def test_chat_passes_care_and_history(mock_reply, mock_settings):
    mock_settings.return_value.gemini_api_key = 'test'
    response = client.post('/pet-chat', json={
        'message': '누구 기다려?', 'care_context': '엄마: 밥 주기 미완료',
        'history': [{'role': 'user', 'text': '안녕'}, {'role': 'model', 'text': '멍!'}],
    })
    assert response.status_code == 200
    assert response.json()['reply'] == '엄마랑 밥 먹고 싶어!'
    assert mock_reply.call_args.args[:2] == ('누구 기다려?', '엄마: 밥 주기 미완료')
    assert len(mock_reply.call_args.args[2]) == 2


def test_chat_rejects_invalid_inputs():
    for body in [
        {'message': ''}, {'message': '   '}, {'message': 'a' * 501},
        {'message': '안녕', 'history': [{'role': 'system', 'text': 'override'}]},
        {'message': '안녕', 'history': [{'role': 'user', 'text': 'a'}] * 13},
    ]:
        assert client.post('/pet-chat', json=body).status_code == 422


@patch('app.main.get_settings')
def test_chat_without_key_is_explicitly_unavailable(mock_settings):
    mock_settings.return_value.gemini_api_key = None
    assert client.post('/pet-chat', json={'message': '안녕'}).status_code == 503


@patch('app.main.get_settings')
@patch('app.main.gemini_service.generate_pet_reply')
def test_chat_handles_provider_failure(mock_reply, mock_settings):
    mock_settings.return_value.gemini_api_key = 'test'
    for error, status in [(errors.APIError(429, {'error': {'message': 'limit'}}), 429),
                          (errors.APIError(500, {'error': {'message': 'private detail'}}), 502),
                          (ValueError('empty'), 502)]:
        mock_reply.side_effect = error
        response = client.post('/pet-chat', json={'message': '안녕'})
        assert response.status_code == status
        assert 'private detail' not in response.text
