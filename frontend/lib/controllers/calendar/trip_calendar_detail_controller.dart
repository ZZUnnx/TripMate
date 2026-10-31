import '../../models/trip_member.dart';
import '../../models/trip_schedule.dart';
import '../../services/chat_service.dart';
import '../../widgets/calendar/presentation/calendar_formatters.dart';
import '../../widgets/calendar/presentation/calendar_transformations.dart';
import '../../widgets/calendar/presentation/calendar_view_data.dart';

class TripCalendarDetailController {
  TripCalendarDetailController({
    required List<TripSchedule> schedules,
    required TripSchedule selectedSchedule,
    Future<List<TripMember>> Function(String token, int tripId)? memberLoader,
  }) : tripId = selectedSchedule.tripId,
       timelineSections = calendarTimelineSectionsFromSchedules(schedules),
       timeRange = calendarTimeRangeFor(schedules),
       dateRange = calendarTripDateRange(selectedSchedule),
       _memberLoader =
           memberLoader ??
           ((token, tripId) =>
               ChatService.fetchMembers(accessToken: token, tripId: tripId));

  final int tripId;
  final List<CalendarTimelineDateSection> timelineSections;
  final String timeRange;
  final String dateRange;
  final Future<List<TripMember>> Function(String token, int tripId)
  _memberLoader;
  Future<List<TripMember>>? _membersFuture;
  String? _accessToken;

  Future<List<TripMember>>? get membersFuture => _membersFuture;

  void updateSession(String? accessToken) {
    if (_accessToken == accessToken && _membersFuture != null) return;
    _accessToken = accessToken;
    _membersFuture = accessToken == null
        ? null
        : _memberLoader(accessToken, tripId);
  }
}
