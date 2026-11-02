import 'package:flutter/material.dart';

import '../../../models/trip_schedule.dart';

class CalendarAgendaItem {
  CalendarAgendaItem({
    required this.schedule,
    required this.category,
    required this.time,
    required this.title,
    required this.color,
    required this.categoryBackground,
    this.subtitle,
    this.reservationLabel,
    this.reservationColor = const Color(0xFFE8A33D),
    this.reservationBackground = const Color(0xFFFFF6DF),
    this.participants,
  });

  final TripSchedule schedule;
  DateTime get date => schedule.scheduledDate;
  final String category;
  final String time;
  final String title;
  final String? subtitle;
  final Color color;
  final Color categoryBackground;
  final String? reservationLabel;
  final Color reservationColor;
  final Color reservationBackground;
  final String? participants;
}

class CalendarTimelineDateSection {
  const CalendarTimelineDateSection({required this.title, required this.items});

  final String title;
  final List<CalendarTripTimelineEntry> items;
}

class CalendarTripTimelineEntry {
  const CalendarTripTimelineEntry({
    required this.schedule,
    required this.time,
    required this.title,
    required this.place,
    required this.status,
    required this.cost,
    required this.dotColor,
  });

  final TripSchedule schedule;
  final String time;
  final String title;
  final String place;
  final CalendarTimelineStatus status;
  final String cost;
  final Color dotColor;
}

class CalendarTimelineStatus {
  const CalendarTimelineStatus({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}

const calendarTravelColor = Color(0xFF148776);

const calendarPersonalColor = Color(0xFF8067B8);

const calendarFreeColor = Color(0xFF4E79C7);

const calendarFreeSchedule = CalendarTimelineStatus(
  label: '자유 일정',
  foreground: calendarFreeColor,
  background: Color(0xFFEAF0FB),
);

class CalendarScheduleDraft {
  const CalendarScheduleDraft({
    required this.tripId,
    required this.title,
    required this.category,
    required this.scheduledDate,
    this.scheduledTime,
    this.placeName,
    this.url,
    this.description,
    this.sortOrder,
  });

  final int tripId;
  final String title;
  final String category;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final String? placeName;
  final String? url;
  final String? description;
  final int? sortOrder;
}
