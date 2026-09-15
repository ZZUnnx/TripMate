import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
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

  static Future<void> createChatRoom({
    required String accessToken,
    required String title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{'title': title};

    if (destination != null && destination.trim().isNotEmpty) {
      body['destination'] = destination.trim();
    }

    if (startDate != null) {
      body['startDate'] = _formatDate(startDate);
    }

    if (endDate != null) {
      body['endDate'] = _formatDate(endDate);
    }

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/trips'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('채팅방을 만들지 못했습니다. (${response.statusCode})');
  }

  static Future<List<ChatMessage>> fetchMessages({
    required String accessToken,
    required int tripId,
  }) async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/chat/rooms/$tripId/messages'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (body is List) {
        return body
            .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw const FormatException('채팅 메시지 응답 형식이 올바르지 않습니다.');
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('채팅 메시지를 불러오지 못했습니다. (${response.statusCode})');
  }

  static Future<ChatMessage> sendMessage({
    required String accessToken,
    required int tripId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/chat/rooms/$tripId/messages'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChatMessage.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('메시지를 보내지 못했습니다. (${response.statusCode})');
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
