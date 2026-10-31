import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/settlement.dart';
import 'auth_service.dart';

class SettlementService {
  static Future<dynamic> _request(
    String method,
    String path,
    String token, [
    Map<String, dynamic>? body,
  ]) async {
    final request =
        http.Request(method, Uri.parse('${AuthService.baseUrl}/api$path'))
          ..headers.addAll({
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(await request.send())
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) throw Exception('로그인이 필요합니다.');
      if (response.statusCode == 403 || response.statusCode == 404) {
        throw Exception('정산 내역이 없거나 접근 권한이 없습니다.');
      }
      throw Exception('정산 요청에 실패했습니다. (${response.statusCode})');
    }
    return response.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<List<SettlementData>> fetchParticipatingTrips({
    required String accessToken,
  }) async {
    final data = await _request('GET', '/settlements', accessToken) as List;
    return data
        .map(
          (item) =>
              SettlementData.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static Future<SettlementData> fetchDetail(String token, int tripId) async =>
      SettlementData.fromJson(
        Map<String, dynamic>.from(
          await _request('GET', '/trips/$tripId/settlement', token) as Map,
        ),
      );
  static Future<void> saveExpense(
    String token,
    int tripId,
    ExpenseDraft draft, {
    int? expenseId,
  }) async {
    await _request(
      expenseId == null ? 'POST' : 'PATCH',
      expenseId == null ? '/trips/$tripId/expenses' : '/expenses/$expenseId',
      token,
      draft.toJson(),
    );
  }

  static Future<void> deleteExpense(String token, int expenseId) async {
    await _request('DELETE', '/expenses/$expenseId', token);
  }

  static Future<void> setCompleted(
    String token,
    int tripId,
    bool completed,
  ) async {
    await _request('PATCH', '/trips/$tripId/settlement', token, {
      'completed': completed,
    });
  }
}
