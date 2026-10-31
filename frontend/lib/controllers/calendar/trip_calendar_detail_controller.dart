import 'package:flutter/foundation.dart';

import '../../models/trip_member.dart';
import '../../models/trip_schedule.dart';
import '../../services/chat_service.dart';
import '../../services/schedule_service.dart';
import '../../widgets/calendar/presentation/calendar_formatters.dart';
import '../../widgets/calendar/presentation/calendar_transformations.dart';
import '../../widgets/calendar/presentation/calendar_view_data.dart';

class TripCalendarDetailController extends ChangeNotifier {
  TripCalendarDetailController({
    required List<TripSchedule> schedules,
    required TripSchedule selectedSchedule,
    Future<List<TripMember>> Function(String token, int tripId)? memberLoader,
    Future<void> Function(String token, int scheduleId)? scheduleDeleter,
  }) : tripId = selectedSchedule.tripId,
       _schedules = List.of(schedules),
       dateRange = calendarTripDateRange(selectedSchedule),
       _memberLoader =
           memberLoader ??
           ((token, tripId) =>
               ChatService.fetchMembers(accessToken: token, tripId: tripId)),
       _scheduleDeleter =
           scheduleDeleter ??
           ((token, id) => ScheduleService.deleteSchedule(
             accessToken: token,
             scheduleId: id,
           ));

  final int tripId;
  final List<TripSchedule> _schedules;
  List<CalendarTimelineDateSection> get timelineSections =>
      calendarTimelineSectionsFromSchedules(_schedules);
  String get timeRange => calendarTimeRangeFor(_schedules);
  int get scheduleCount => _schedules.length;
  final String dateRange;
  final Future<List<TripMember>> Function(String token, int tripId)
  _memberLoader;
  final Future<void> Function(String token, int scheduleId) _scheduleDeleter;
  final _deletingIds = <int>{};
  Set<int> get deletingIds => Set.unmodifiable(_deletingIds);
  bool _disposed = false;
  Future<List<TripMember>>? _membersFuture;
  String? _accessToken;

  Future<List<TripMember>>? get membersFuture => _membersFuture;

  void updateSession(String? accessToken) {
    if (_disposed) return;
    if (_accessToken == accessToken && _membersFuture != null) return;
    _accessToken = accessToken;
    _membersFuture = accessToken == null
        ? null
        : _memberLoader(accessToken, tripId);
  }

  Future<bool> deleteSchedule(int scheduleId) async {
    final token = _accessToken;
    if (_disposed ||
        _deletingIds.contains(scheduleId) ||
        !_schedules.any((schedule) => schedule.id == scheduleId)) {
      return false;
    }
    if (token == null) throw StateError('로그인이 필요합니다.');
    _deletingIds.add(scheduleId);
    notifyListeners();
    try {
      await _scheduleDeleter(token, scheduleId);
      if (!_disposed) {
        _schedules.removeWhere((schedule) => schedule.id == scheduleId);
      }
      return true;
    } finally {
      _deletingIds.remove(scheduleId);
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
