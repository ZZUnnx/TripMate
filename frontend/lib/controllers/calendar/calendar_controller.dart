import 'package:flutter/foundation.dart';

import '../../models/trip.dart';
import '../../models/trip_schedule.dart';
import '../../services/schedule_service.dart';
import '../../widgets/calendar/presentation/calendar_data.dart';
import '../../widgets/calendar/presentation/calendar_transformations.dart';
import '../../widgets/calendar/presentation/calendar_view_data.dart';

class CalendarController extends ChangeNotifier {
  CalendarController({
    Future<List<Trip>> Function(String token)? tripLoader,
    Future<List<TripSchedule>> Function(String token, int tripId)?
    scheduleLoader,
    Future<void> Function(String token, CalendarScheduleDraft draft)?
    scheduleCreator,
  }) : _tripLoader =
           tripLoader ??
           ((token) => ScheduleService.fetchTrips(accessToken: token)),
       _scheduleLoader =
           scheduleLoader ??
           ((token, tripId) => ScheduleService.fetchTripSchedules(
             accessToken: token,
             tripId: tripId,
           )),
       _scheduleCreator = scheduleCreator ?? _createSchedule;

  final Future<List<Trip>> Function(String token) _tripLoader;
  final Future<List<TripSchedule>> Function(String token, int tripId)
  _scheduleLoader;
  final Future<void> Function(String token, CalendarScheduleDraft draft)
  _scheduleCreator;
  Future<CalendarData>? _calendarFuture;
  String? _accessToken;
  bool _disposed = false;

  Future<CalendarData>? get calendarFuture => _calendarFuture;

  // The screen calls this from didChangeDependencies, which already schedules a build.
  void updateSession({
    required bool isInitialized,
    required String? accessToken,
  }) {
    if (_disposed || !isInitialized) return;
    if (_accessToken == accessToken && _calendarFuture != null) return;
    _accessToken = accessToken;
    _calendarFuture = accessToken == null ? null : _loadCalendar(accessToken);
  }

  Future<CalendarData> _loadCalendar(String token) async {
    final trips = await _tripLoader(token);
    final scheduleGroups = await Future.wait(
      trips.map((trip) => _scheduleLoader(token, trip.id)),
    );
    final schedules = scheduleGroups.expand((items) => items).toList()
      ..sort(calendarCompareTripSchedules);
    return CalendarData(trips: trips, schedules: schedules);
  }

  void reload() {
    final token = _accessToken;
    if (_disposed || token == null) return;
    _calendarFuture = _loadCalendar(token);
    notifyListeners();
  }

  Future<void> addSchedule(
    CalendarScheduleDraft draft, {
    required String accessToken,
  }) async {
    if (_disposed) return;
    await _scheduleCreator(accessToken, draft);
    if (!_disposed && _accessToken == accessToken) reload();
  }

  static Future<void> _createSchedule(
    String token,
    CalendarScheduleDraft draft,
  ) async {
    await ScheduleService.createScheduleFromInput(
      accessToken: token,
      tripId: draft.tripId,
      title: draft.title,
      scheduledDate: draft.scheduledDate,
      category: draft.category,
      scheduledTime: draft.scheduledTime,
      placeName: draft.placeName,
      url: draft.url,
      description: draft.description,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
