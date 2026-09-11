import 'package:flutter/material.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.timeLabel,
    required this.location,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String title;
  final String timeLabel;
  final String location;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

final Map<DateTime, List<CalendarEvent>> calendarEvents = {
  DateTime.utc(2024, 9, 2): [
    const CalendarEvent(
      title: '항공권 확인',
      timeLabel: '09:00',
      location: '온라인',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF635BFF),
      backgroundColor: Color(0xFFECE8FF),
    ),
  ],
  DateTime.utc(2024, 9, 9): [
    const CalendarEvent(
      title: '여행 준비',
      timeLabel: '18:00',
      location: '집',
      icon: Icons.checklist_rounded,
      color: Color(0xFF35AFA5),
      backgroundColor: Color(0xFFE2F6F3),
    ),
  ],
  DateTime.utc(2024, 9, 11): [
    const CalendarEvent(
      title: '예약금 정산',
      timeLabel: '12:00',
      location: '앱',
      icon: Icons.payments_outlined,
      color: Color(0xFFF05A7A),
      backgroundColor: Color(0xFFFFE5EC),
    ),
  ],
  DateTime.utc(2024, 9, 13): [
    const CalendarEvent(
      title: '데이터베이스 수업',
      timeLabel: '10:00\n11:00',
      location: '공학관 301호',
      icon: Icons.school_rounded,
      color: Color(0xFF52BFAF),
      backgroundColor: Color(0xFFE0F5F1),
    ),
    const CalendarEvent(
      title: '팀 프로젝트 회의',
      timeLabel: '14:00\n16:00',
      location: '스터디룸 B',
      icon: Icons.groups_rounded,
      color: Color(0xFF7A67FF),
      backgroundColor: Color(0xFFECE8FF),
    ),
    const CalendarEvent(
      title: '친구들과 저녁',
      timeLabel: '19:00\n20:30',
      location: '서면',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF05A7A),
      backgroundColor: Color(0xFFFFE5EC),
    ),
  ],
  DateTime.utc(2024, 9, 14): [
    const CalendarEvent(
      title: '체크인',
      timeLabel: '15:00',
      location: '호텔',
      icon: Icons.hotel_rounded,
      color: Color(0xFF635BFF),
      backgroundColor: Color(0xFFECE8FF),
    ),
  ],
  DateTime.utc(2024, 9, 15): [
    const CalendarEvent(
      title: '브런치',
      timeLabel: '11:00',
      location: '카페',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFFF05A7A),
      backgroundColor: Color(0xFFFFE5EC),
    ),
  ],
  DateTime.utc(2024, 9, 17): [
    const CalendarEvent(
      title: '일정 공유',
      timeLabel: '13:00',
      location: '채팅',
      icon: Icons.chat_bubble_rounded,
      color: Color(0xFF2998D1),
      backgroundColor: Color(0xFFE3F4FF),
    ),
  ],
  DateTime.utc(2024, 9, 18): [
    const CalendarEvent(
      title: '회의',
      timeLabel: '16:00',
      location: '강의실',
      icon: Icons.groups_rounded,
      color: Color(0xFF635BFF),
      backgroundColor: Color(0xFFECE8FF),
    ),
  ],
  DateTime.utc(2024, 9, 23): [
    const CalendarEvent(
      title: '정산 확인',
      timeLabel: '20:00',
      location: '앱',
      icon: Icons.payments_outlined,
      color: Color(0xFFB65C98),
      backgroundColor: Color(0xFFF6E3F0),
    ),
  ],
  DateTime.utc(2024, 9, 26): [
    const CalendarEvent(
      title: '출발 준비',
      timeLabel: '21:00',
      location: '집',
      icon: Icons.luggage_rounded,
      color: Color(0xFF35AFA5),
      backgroundColor: Color(0xFFE2F6F3),
    ),
  ],
};

List<CalendarEvent> eventsForDay(DateTime day) {
  return calendarEvents[DateTime.utc(day.year, day.month, day.day)] ?? const [];
}

String weekdayName(DateTime day) {
  return const ['월', '화', '수', '목', '금', '토', '일'][day.weekday - 1];
}

String detailTimeLabel(String timeLabel) {
  final times = timeLabel.split('\n');

  if (times.length == 1) {
    return times.first;
  }

  return '${times.first} - ${times.last}';
}
