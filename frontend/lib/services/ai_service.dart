import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String baseUrl = 'http://100.79.181.89:8080';

  static Future<List<dynamic>> analyzeChat(int tripId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/trips/$tripId/ai/analyze'),
      headers: {
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