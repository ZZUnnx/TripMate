import 'package:flutter/material.dart';

import '../../../models/trip_schedule.dart';
import 'calendar_formatters.dart';
import 'calendar_view_data.dart';

List<DateTime> calendarDaysFor(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final sundayOffset = firstDay.weekday % 7;
  final gridStart = firstDay.subtract(Duration(days: sundayOffset));

  return List.generate(35, (index) => gridStart.add(Duration(days: index)));
}

List<Color> calendarMarkerColorsFor(
  DateTime day,
  List<CalendarAgendaItem> agendaItems,
) {
  final items = calendarAgendaFor(day, agendaItems);
  final colors = <Color>[];

  if (items.any((item) => item.category == '개인')) {
    colors.add(calendarPersonalColor);
  }
  if (items.any((item) => item.category == '공유 여행')) {
    colors.add(calendarTravelColor);
  }

  return colors;
}

List<CalendarAgendaItem> calendarAgendaFor(
  DateTime day,
  List<CalendarAgendaItem> agendaItems,
) {
  return agendaItems
      .where((item) => calendarIsSameDate(item.date, day))
      .toList(growable: false);
}

CalendarAgendaItem calendarAgendaItemFromSchedule(TripSchedule schedule) {
  final category = schedule.category == '개인' ? '개인' : '공유 여행';
  final color = category == '개인' ? calendarPersonalColor : calendarTravelColor;
  final place = schedule.placeName ?? schedule.tripDestination;

  return CalendarAgendaItem(
    schedule: schedule,
    category: category,
    time: calendarFormatScheduleTime(schedule.scheduledTime),
    title: schedule.title,
    subtitle: [schedule.tripTitle, ?place].join(' · '),
    color: color,
    categoryBackground: category == '개인'
        ? const Color(0xFFF0ECF8)
        : const Color(0xFFDDF3EE),
    reservationLabel: '확정',
    reservationColor: const Color(0xFF2F9D69),
    reservationBackground: const Color(0xFFE5F6EE),
    participants: category == '공유 여행' ? '공유' : null,
  );
}

List<CalendarTimelineDateSection> calendarTimelineSectionsFromSchedules(
  List<TripSchedule> schedules,
) {
  final grouped = <String, List<TripSchedule>>{};

  for (final schedule in schedules) {
    final key = calendarDateKey(schedule.scheduledDate);
    grouped.putIfAbsent(key, () => []).add(schedule);
  }

  final dates = grouped.keys.toList()..sort();

  return dates.map((key) {
    final items = grouped[key]!..sort(calendarCompareTripSchedules);
    final date = items.first.scheduledDate;

    return CalendarTimelineDateSection(
      title: calendarFormatFullDate(date),
      items: items.map(calendarTimelineEntryFromSchedule).toList(),
    );
  }).toList();
}

CalendarTripTimelineEntry calendarTimelineEntryFromSchedule(
  TripSchedule schedule,
) {
  final category = schedule.category == '개인' ? '개인' : '공유 여행';
  final dotColor = category == '개인'
      ? calendarPersonalColor
      : calendarTravelColor;

  return CalendarTripTimelineEntry(
    schedule: schedule,
    time: calendarFormatScheduleTime(schedule.scheduledTime),
    title: schedule.title,
    place: schedule.placeName ?? schedule.description ?? '장소 미정',
    status: category == '개인'
        ? calendarFreeSchedule
        : CalendarTimelineStatus(
            label: schedule.category,
            foreground: const Color(0xFF0B5F55),
            background: const Color(0xFFDDF3EE),
          ),
    cost: '비용 미정',
    dotColor: dotColor,
  );
}

int calendarCompareTripSchedules(TripSchedule left, TripSchedule right) {
  final dateCompare = left.scheduledDate.compareTo(right.scheduledDate);

  if (dateCompare != 0) {
    return dateCompare;
  }

  final timeCompare = (left.scheduledTime ?? '').compareTo(
    right.scheduledTime ?? '',
  );

  if (timeCompare != 0) {
    return timeCompare;
  }

  final orderCompare = left.sortOrder.compareTo(right.sortOrder);

  if (orderCompare != 0) {
    return orderCompare;
  }

  return left.id.compareTo(right.id);
}

bool calendarIsSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
