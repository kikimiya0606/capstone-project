import 'dart:convert';

import 'package:http/http.dart' as http;

// 로컬 개발용 ai-server 주소. 실기기(Android 에뮬레이터 등)에서 테스트할 땐 값이 달라질 수 있음.
const _aiServerBaseUrl = 'http://localhost:8000';

class AiServerException implements Exception {
  AiServerException(this.message);
  final String message;
}

class PetPhotoAnalysis {
  PetPhotoAnalysis({required this.breed, required this.colorDescription});
  final String breed;
  final String colorDescription;
}

class AiServerService {
  AiServerService._();
  static final instance = AiServerService._();

  Future<PetPhotoAnalysis> analyzePetPhotos(List<List<int>> images) async {
    final uri = Uri.parse('$_aiServerBaseUrl/analyze-pet-photo');
    final request = http.MultipartRequest('POST', uri);
    for (var i = 0; i < images.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes('images', images[i], filename: 'photo_$i.jpg'),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      String detail;
      try {
        detail = (jsonDecode(response.body) as Map)['detail'] as String? ?? response.body;
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
