import '../../../models/trip_schedule.dart';
import 'calendar_view_data.dart';

String calendarAgendaSummary(List<CalendarAgendaItem> agendas) {
  final travelCount = agendas.where((item) => item.category == '공유 여행').length;
  final personalCount = agendas.where((item) => item.category == '개인').length;

  return '공유 여행 $travelCount개 · 개인 $personalCount개';
}

String calendarTimeRangeFor(List<TripSchedule> schedules) {
  final times =
      schedules
          .map((schedule) => schedule.scheduledTime)
          .whereType<String>()
          .toList()
        ..sort();

  if (times.isEmpty) {
    return '시간 미정';
  }

  if (times.length == 1) {
    return calendarFormatScheduleTime(times.first);
  }

  return '${calendarFormatScheduleTime(times.first)} - ${calendarFormatScheduleTime(times.last)}';
}

String calendarTripDateRange(TripSchedule schedule) {
  final startDate = schedule.tripStartDate;
  final endDate = schedule.tripEndDate;

  if (startDate != null && endDate != null) {
    return '${calendarFormatShortDate(startDate)} - ${calendarFormatShortDate(endDate)}';
  }

  return calendarFormatShortDate(schedule.scheduledDate);
}

String calendarFormatScheduleTime(String? time) {
  if (time == null || time.isEmpty) {
    return '시간 미정';
  }

  final parts = time.split(':');

  if (parts.length >= 2) {
    return '${parts[0]}:${parts[1]}';
  }

  return time;
}

String calendarFormatShortDate(DateTime date) {
  return '${date.month}월 ${date.day}일';
}

String calendarFormatFullDate(DateTime date) {
  return '${date.month}월 ${date.day}일 ${calendarWeekdayName(date)}요일';
}

String calendarFormatWon(int amount) {
  final value = amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );

  return '$value원';
}

String calendarWeekdayName(DateTime date) {
  return const ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
}

String calendarDateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}
