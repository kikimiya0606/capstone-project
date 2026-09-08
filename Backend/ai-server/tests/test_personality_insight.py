from unittest.mock import AsyncMock, MagicMock, patch
import httpx
from fastapi.testclient import TestClient
from google.genai import errors as genai_errors
from app.main import app
from app.pet_personality import personality_instruction
from app.gemini_service import generate_family_signal, generate_pet_reply
from app.ollama_service import chat
from app.schemas import PetChatTurn
import asyncio

client = TestClient(app)


def test_all_four_personality_dimensions_change_prompt():
    base = personality_instruction([0, 0, 0, 0], '콩이')
    assert '콩이' in base
    for axis in range(4):
        answers = [0] * 4
        answers[axis] = 2
        assert personality_instruction(answers, '콩이') != base
    assert '단정하지' in personality_instruction([])


@patch('app.main.get_settings')
@patch('app.main.gemini_service.generate_pet_reply', return_value='조금 더 기다려볼게.')
def test_saved_personality_reaches_provider(reply, settings):
    settings.return_value.gemini_api_key = 'test'
    r = client.post('/pet-chat', json={'message': '기다려', 'pet_name': '콩이', 'personality_answers': [2, 1, 2, 1]})
    assert r.status_code == 200
    assert reply.call_args.args[3:] == ('콩이', [2, 1, 2, 1])
    for answers in [[1], [-1, 0, 0, 0], [3, 0, 0, 0], [True, 0, 0, 0], ['1', 0, 0, 0]]:
        assert client.post('/pet-chat', json={'message': '안녕', 'personality_answers': answers}).status_code == 422


@patch('app.gemini_service.get_client')
def test_gemini_system_prompt_contains_observations(get_client):
    get_client.return_value.models.generate_content.return_value.text = '같이 놀자!'
    generate_pet_reply('안녕', '오늘 밥 완료', [], '콩이', [2, 2, 1, 0])
    instruction = get_client.return_value.models.generate_content.call_args.kwargs['config'].system_instruction
    assert '차분하고' in instruction and '수줍고' in instruction and '애교' in instruction
    assert '콩이' in instruction and '오늘 밥 완료' in instruction


@patch('app.main.ollama_service.chat', new_callable=AsyncMock)
def test_insight_passes_context_and_reports_unavailability(chat_mock):
    chat_mock.return_value = '식물을 좋아하신다고 하니 작은 화분은 어때요?'
    body = {'message': '엄마 선물 추천', 'family_context': '엄마: 식물을 좋아함', 'history': [{'role': 'user', 'text': '예산은 3만원'}]}
    assert client.post('/insight-chat', json=body).status_code == 200
    assert chat_mock.call_args.args[1] == body['family_context']
    for exc, status in [(httpx.ConnectError('offline'), 503), (httpx.ReadTimeout('slow'), 504), (ValueError('empty'), 502)]:
        chat_mock.side_effect = exc
        assert client.post('/insight-chat', json=body).status_code == status
    assert client.post('/insight-chat', json={'message': ' '}).status_code == 422


@patch('app.gemini_service.get_client')
def test_family_signal_prompt_includes_interaction_data(get_client):
    get_client.return_value.models.generate_content.return_value.text = '다들 잘 지내고 있어요.'
    generate_family_signal('가족 구성원: 아빠, 지우', '아빠(아빠) - 지우(딸): 교류 0회')
    prompt = get_client.return_value.models.generate_content.call_args.kwargs['contents']
    assert '아빠(아빠) - 지우(딸): 교류 0회' in prompt
    assert '가족 구성원: 아빠, 지우' in prompt


@patch('app.main.gemini_service.generate_family_signal', return_value='아빠와 지우의 대화가 뜸해 보여요.')
def test_family_signal_passes_context_and_interaction_summary(signal_mock):
    body = {
        'family_context': '가족 구성원: 아빠, 지우',
        'interaction_summary': '아빠(아빠) - 지우(딸): 교류 0회',
    }
    r = client.post('/family-signal', json=body)
    assert r.status_code == 200
    assert r.json()['reply'] == '아빠와 지우의 대화가 뜸해 보여요.'
    assert signal_mock.call_args.args == (body['family_context'], body['interaction_summary'])


@patch('app.main.gemini_service.generate_family_signal')
def test_family_signal_reports_provider_failure(signal_mock):
    signal_mock.side_effect = genai_errors.APIError(429, {'error': {'message': 'x', 'status': 'RESOURCE_EXHAUSTED'}})
    assert client.post('/family-signal', json={}).status_code == 429
    signal_mock.side_effect = genai_errors.APIError(500, {'error': {'message': 'x', 'status': 'INTERNAL'}})
    assert client.post('/family-signal', json={}).status_code == 502


@patch('app.ollama_service.httpx.AsyncClient')
def test_ollama_uses_chat_history_and_non_stream_response(http):
    response = MagicMock()
    response.json.return_value = {'message': {'content': '{"reply": "추천이에요"}'}}
    post = AsyncMock(return_value=response)
    http.return_value.__aenter__.return_value.post = post
    result = asyncio.run(chat('더 추천해줘', '엄마: 식물', [PetChatTurn(role='model', text='화분은 어때요?')]))
    assert result == '추천이에요'
    body = post.call_args.kwargs['json']
    assert body['stream'] is False
    assert body['think'] is False
    assert body['format']['required'] == ['reply']
    assert body['messages'][1] == {'role': 'assistant', 'content': '화분은 어때요?'}
    assert '엄마: 식물' in body['messages'][0]['content']
