from unittest.mock import MagicMock, patch

import pytest
from google.genai import errors as genai_errors

from app.gemini_service import _generate_content


def _api_error(code: int) -> genai_errors.APIError:
    return genai_errors.APIError(code, {"error": {"message": "boom", "status": "UNAVAILABLE"}})


@patch("app.gemini_service.time.sleep")
@patch("app.gemini_service.get_client")
def test_retries_on_transient_error_then_succeeds(mock_get_client, mock_sleep):
    mock_response = MagicMock()
    mock_get_client.return_value.models.generate_content.side_effect = [
        _api_error(503),
        _api_error(503),
        mock_response,
    ]

    result = _generate_content(model="gemini-3.6-flash", contents="hi")

    assert result is mock_response
    assert mock_get_client.return_value.models.generate_content.call_count == 3
    assert mock_sleep.call_count == 2


@patch("app.gemini_service.time.sleep")
@patch("app.gemini_service.get_client")
def test_gives_up_after_max_attempts(mock_get_client, mock_sleep):
    mock_get_client.return_value.models.generate_content.side_effect = _api_error(503)

    with pytest.raises(genai_errors.APIError):
        _generate_content(model="gemini-3.6-flash", contents="hi")

    assert mock_get_client.return_value.models.generate_content.call_count == 3


@patch("app.gemini_service.time.sleep")
@patch("app.gemini_service.get_client")
def test_does_not_retry_non_transient_error(mock_get_client, mock_sleep):
    mock_get_client.return_value.models.generate_content.side_effect = _api_error(400)

    with pytest.raises(genai_errors.APIError):
        _generate_content(model="gemini-3.6-flash", contents="hi")

    assert mock_get_client.return_value.models.generate_content.call_count == 1
    mock_sleep.assert_not_called()
