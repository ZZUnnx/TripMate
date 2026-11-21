import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AiService {
  static Future<List<dynamic>> analyzeChat({
    required int tripId,
    required String accessToken,
  }) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/trips/$tripId/ai/analyze'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('AI 채팅 분석에 실패했습니다.');
    }

    final data = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    return data['items'] ?? [];
  }
}
