from unittest.mock import MagicMock, patch

from app.emotion_model import EmotionClassifier, LABELS, get_classifier


@patch("transformers.AutoModelForSequenceClassification.from_pretrained")
@patch("transformers.AutoTokenizer.from_pretrained")
def test_emotion_classifier_passes_hf_token_through(mock_tokenizer_from_pretrained, mock_model_from_pretrained):
    mock_model_from_pretrained.return_value = MagicMock()

    EmotionClassifier("some-org/some-model", hf_token="secret-token")

    mock_tokenizer_from_pretrained.assert_called_once_with("some-org/some-model", token="secret-token")
    mock_model_from_pretrained.assert_called_once_with("some-org/some-model", token="secret-token")


@patch("transformers.AutoModelForSequenceClassification.from_pretrained")
@patch("transformers.AutoTokenizer.from_pretrained")
def test_emotion_classifier_hf_token_defaults_to_none(mock_tokenizer_from_pretrained, mock_model_from_pretrained):
    mock_model_from_pretrained.return_value = MagicMock()

    EmotionClassifier("klue/bert-base")

    mock_tokenizer_from_pretrained.assert_called_once_with("klue/bert-base", token=None)
    mock_model_from_pretrained.assert_called_once_with("klue/bert-base", token=None)


@patch("transformers.AutoModelForSequenceClassification.from_pretrained")
@patch("transformers.AutoTokenizer.from_pretrained")
def test_predict_returns_label_for_argmax_logit(mock_tokenizer_from_pretrained, mock_model_from_pretrained):
    import torch

    mock_tokenizer = MagicMock()
    mock_tokenizer.return_value = {"input_ids": torch.zeros((1, 4), dtype=torch.long)}
    mock_tokenizer_from_pretrained.return_value = mock_tokenizer

    mock_model = MagicMock()
    mock_output = MagicMock()
    # LABELS = ["불안", "분노", "상처", "슬픔", "당황", "기쁨"] -> index 3 == "슬픔"
    mock_output.logits = torch.tensor([[0.0, 0.0, 0.0, 5.0, 0.0, 0.0]])
    mock_model.return_value = mock_output
    mock_model_from_pretrained.return_value = mock_model

    classifier = EmotionClassifier("klue/bert-base")

    assert classifier.predict("아무 문장") == "슬픔"
    assert LABELS[3] == "슬픔"


@patch("app.emotion_model.EmotionClassifier")
def test_get_classifier_passes_settings(mock_classifier_cls):
    import app.emotion_model as emotion_model

    emotion_model._classifier = None
    with patch("app.emotion_model.get_settings") as mock_get_settings:
        mock_get_settings.return_value.emotion_model_path = "some-org/some-model"
        mock_get_settings.return_value.hf_token = "secret-token"
        get_classifier()

    mock_classifier_cls.assert_called_once_with("some-org/some-model", "secret-token")
    emotion_model._classifier = None
