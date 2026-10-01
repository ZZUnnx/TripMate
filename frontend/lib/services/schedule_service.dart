import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/trip.dart';
import '../models/trip_schedule.dart';
import 'auth_service.dart';

class ScheduleService {
  static Future<List<Trip>> fetchTrips({required String accessToken}) async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/trips'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (body is List) {
        return body
            .map((item) => Trip.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw const FormatException('여행 목록 응답 형식이 올바르지 않습니다.');
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('여행 목록을 불러오지 못했습니다. (${response.statusCode})');
  }

  static Future<List<TripSchedule>> fetchTripSchedules({
    required String accessToken,
    required int tripId,
  }) async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/api/trips/$tripId/schedules'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (body is List) {
        return body
            .map((item) => TripSchedule.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw const FormatException('일정 목록 응답 형식이 올바르지 않습니다.');
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('일정 목록을 불러오지 못했습니다. (${response.statusCode})');
  }

  static Future<List<TripSchedule>> fetchAllSchedules({
    required String accessToken,
  }) async {
    final trips = await fetchTrips(accessToken: accessToken);
    final scheduleGroups = await Future.wait(
      trips.map(
        (trip) => fetchTripSchedules(accessToken: accessToken, tripId: trip.id),
      ),
    );

    return scheduleGroups.expand((schedules) => schedules).toList()
      ..sort(_compareSchedules);
  }

  static Future<TripSchedule> createSchedule({
    required String accessToken,
    required int tripId,
    required TripSchedule schedule,
  }) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/api/trips/$tripId/schedules'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(schedule.toRequestJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TripSchedule.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('일정을 만들지 못했습니다. (${response.statusCode})');
  }

  static Future<TripSchedule> updateSchedule({
    required String accessToken,
    required TripSchedule schedule,
  }) async {
    final response = await http.patch(
      Uri.parse('${AuthService.baseUrl}/api/schedules/${schedule.id}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(schedule.toRequestJson()),
    );

    if (response.statusCode == 200) {
      return TripSchedule.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('일정을 수정하지 못했습니다. (${response.statusCode})');
  }

  static Future<void> deleteSchedule({
    required String accessToken,
    required int scheduleId,
  }) async {
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/api/schedules/$scheduleId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception('로그인이 필요합니다.');
    }

    throw Exception('일정을 삭제하지 못했습니다. (${response.statusCode})');
  }

  static int _compareSchedules(TripSchedule left, TripSchedule right) {
    final dateCompare = left.scheduledDate.compareTo(right.scheduledDate);

    if (dateCompare != 0) {
      return dateCompare;
    }

    final leftTime = left.scheduledTime ?? '';
    final rightTime = right.scheduledTime ?? '';
    final timeCompare = leftTime.compareTo(rightTime);

    if (timeCompare != 0) {
      return timeCompare;
    }

    final orderCompare = left.sortOrder.compareTo(right.sortOrder);

    if (orderCompare != 0) {
      return orderCompare;
    }

    return left.id.compareTo(right.id);
  }
}
