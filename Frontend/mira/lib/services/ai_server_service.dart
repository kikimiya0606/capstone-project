import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

// 로컬 개발용 ai-server 주소. 실기기(Android 에뮬레이터 등)에서 테스트할 땐 값이 달라질 수 있음.
const _aiServerBaseUrl = String.fromEnvironment(
  'AI_SERVER_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

class AiServerException implements Exception {
  AiServerException(this.message);
  final String message;
}

class PetPhotoAnalysis {
  PetPhotoAnalysis({required this.breed, required this.colorDescription});
  final String breed;
  final String colorDescription;
}

/// klue/bert-base 감정 분류 6종. Backend/ai-server/app/emotion_model.py의 LABELS와 동일해야 한다.
const moodTags = ['기쁨', '슬픔', '분노', '불안', '상처', '당황'];

class MoodAnalysisResult {
  MoodAnalysisResult({
    required this.aiEmotion,
    required this.selfMessage,
    required this.familyMessage,
  });
  final String aiEmotion;
  final String selfMessage;
  final String familyMessage;

  /// "기쁨"이 아니면 가족에게 알림을 보낼 만큼 마음이 안 좋은 상태로 취급한다.
  bool get isNegative => aiEmotion != '기쁨';
}

class AiServerService {
  AiServerService._();
  static final instance = AiServerService._();

  Future<String> chatWithPet({
    required String message,
    required String careContext,
    required List<Map<String, String>> history,
    String petName = '',
    List<int> personalityAnswers = const [],
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_aiServerBaseUrl/pet-chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'care_context': careContext,
              'history': history,
              'pet_name': petName,
              'personality_answers': personalityAnswers,
            }),
          )
          .timeout(const Duration(seconds: 90));
      if (response.statusCode != 200) {
        throw AiServerException(switch (response.statusCode) {
          429 => 'AI 요청 한도에 도달했어요. 잠시 후 다시 시도해주세요.',
          503 => 'AI 서버의 키 설정이 필요해요.',
          502 => 'AI 제공자의 답변을 받지 못했어요. 서버 설정을 확인해주세요.',
          _ => '대화 요청이 실패했어요. (HTTP ${response.statusCode})',
        });
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map ||
          data['reply'] is! String ||
          (data['reply'] as String).trim().isEmpty) {
        throw const FormatException('Invalid pet reply');
      }
      return data['reply'] as String;
    } on TimeoutException {
      throw AiServerException('AI 답변이 90초 안에 도착하지 않았어요. 잠시 후 다시 보내주세요.');
    } on FormatException {
      throw AiServerException('서버 답변 형식이 올바르지 않아요. AI 서버 버전을 확인해주세요.');
    } on AiServerException {
      rethrow;
    } catch (_) {
      throw AiServerException('강아지 대화 서버에 연결하지 못했어요.');
    }
  }

  /// 오늘의 감정 한 줄 기록을 kobert로 분석하고, 본인용/가족용 공감 메시지를 생성한다.
  Future<String> chatInsight({
    required String message,
    required String familyContext,
    required List<Map<String, String>> history,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_aiServerBaseUrl/insight-chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'family_context': familyContext,
              'history': history,
            }),
          )
          .timeout(const Duration(seconds: 130));
      if (response.statusCode != 200) {
        throw AiServerException(
          '인사이트 대화가 연결되지 않았어요. 잠시 후 다시 시도해주세요. (${response.statusCode})',
        );
      }
      final reply =
          (jsonDecode(utf8.decode(response.bodyBytes)) as Map)['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const FormatException();
      }
      return reply;
    } on AiServerException {
      rethrow;
    } on TimeoutException {
      throw AiServerException('답변이 오래 걸려요. 잠시 후 다시 보내주세요.');
    } catch (_) {
      throw AiServerException('인사이트 서버에 연결하지 못했어요.');
    }
  }

  /// 가족 구성원 간 댓글/좋아요 교류 데이터를 보고 소통이 뜸한 관계를 짚어주는
  /// 한 문장을 생성한다. insight-chat(로컬 Ollama)과 달리 숫자 비교/형식 준수가
  /// 중요해서 Gemini(gemini_service)를 쓰는 전용 엔드포인트를 따로 둔다.
  Future<String> familySignal({
    required String familyContext,
    required String interactionSummary,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_aiServerBaseUrl/family-signal'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'family_context': familyContext,
              'interaction_summary': interactionSummary,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw AiServerException(
          '소통 신호를 불러오지 못했어요. 잠시 후 다시 시도해주세요. (${response.statusCode})',
        );
      }
      final reply =
          (jsonDecode(utf8.decode(response.bodyBytes)) as Map)['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const FormatException();
      }
      return reply;
    } on AiServerException {
      rethrow;
    } on TimeoutException {
      throw AiServerException('답변이 오래 걸려요. 잠시 후 다시 시도해주세요.');
    } catch (_) {
      throw AiServerException('소통 신호 서버에 연결하지 못했어요.');
    }
  }

  /// family_message는 일기 원문을 그대로 노출하지 않고 요약해서 전달하도록 서버에서 만들어준다.
  Future<MoodAnalysisResult> analyzeMood({
    required String moodText,
    required String moodTag,
    required String userRole,
    required List<String> familyRoles,
  }) async {
    final uri = Uri.parse('$_aiServerBaseUrl/analyze-mood');
    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'mood_text': moodText,
              'mood_tag': moodTag,
              'user_role': userRole,
              'family_roles': familyRoles,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw AiServerException('AI 서버에 연결하지 못했어요. ai-server가 실행 중인지 확인해주세요.');
    }

    if (response.statusCode != 200) {
      String detail;
      try {
        detail =
            (jsonDecode(response.body) as Map)['detail'] as String? ??
            response.body;
      } catch (_) {
        detail = response.body;
      }
      throw AiServerException(detail);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return MoodAnalysisResult(
      aiEmotion: data['ai_emotion'] as String,
      selfMessage: data['self_message'] as String,
      familyMessage: data['family_message'] as String,
    );
  }

  Future<PetPhotoAnalysis> analyzePetPhotos(List<List<int>> images) async {
    final uri = Uri.parse('$_aiServerBaseUrl/analyze-pet-photo');
    final request = http.MultipartRequest('POST', uri);
    for (var i = 0; i < images.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          images[i],
          filename: 'photo_$i.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      String detail;
      try {
        detail =
            (jsonDecode(response.body) as Map)['detail'] as String? ??
            response.body;
      } catch (_) {
        detail = response.body;
      }
      throw AiServerException(detail);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PetPhotoAnalysis(
      breed: data['breed'] as String,
      colorDescription: data['color_description'] as String,
    );
  }
}
