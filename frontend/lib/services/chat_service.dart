import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_room.dart';
import 'auth_service.dart';

class ChatService {
  static Future<List<ChatRoom>> fetchChatRooms({
    required String accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/chat/rooms'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (body is List) {
        return body
            .map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw const FormatException('채팅 목록 응답 형식이 올바르지 않습니다.');
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('채팅 목록을 불러오지 못했습니다. (${response.statusCode})');
  }
}
