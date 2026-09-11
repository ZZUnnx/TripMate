import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common/responsive.dart';
import 'calendar_event.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.onFocusedDayChanged,
    required this.onSelectedDayChanged,
    super.key,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onFocusedDayChanged;
  final void Function(DateTime selectedDay, DateTime focusedDay)
  onSelectedDayChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                onFocusedDayChanged(
                  DateTime.utc(focusedDay.year, focusedDay.month - 1),
                );
              },
              icon: const Icon(Icons.chevron_left_rounded),
              color: const Color(0xFF424969),
              iconSize: context.rs(32),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(
                Size(context.rs(40), context.rs(40)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${focusedDay.year}년 ${focusedDay.month}월',
                  style: TextStyle(
                    color: const Color(0xFF060914),
                    fontSize: context.rs(20),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                onFocusedDayChanged(
                  DateTime.utc(focusedDay.year, focusedDay.month + 1),
                );
              },
              icon: const Icon(Icons.chevron_right_rounded),
              color: const Color(0xFF424969),
              iconSize: context.rs(32),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(
                Size(context.rs(40), context.rs(40)),
              ),
            ),
          ],
        ),
        const ResponsiveGap(height: 12),
        TableCalendar<CalendarEvent>(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          onDaySelected: onSelectedDayChanged,
          onPageChanged: onFocusedDayChanged,
          eventLoader: eventsForDay,
          headerVisible: false,
          daysOfWeekHeight: context.rs(26),
          rowHeight: context.rs(43),
          availableGestures: AvailableGestures.horizontalSwipe,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          calendarBuilders: CalendarBuilders<CalendarEvent>(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) {
                return null;
              }

              return Positioned(
                bottom: context.rs(5),
                child: Container(
                  width: context.rs(5),
                  height: context.rs(5),
                  decoration: BoxDecoration(
                    color: events.first.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            dowTextFormatter: (date, locale) {
              return const ['일', '월', '화', '수', '목', '금', '토'][date.weekday %
                  7];
            },
            weekdayStyle: TextStyle(
              color: const Color(0xFF636A80),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w800,
            ),
            weekendStyle: TextStyle(
              color: const Color(0xFF636A80),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w800,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideTextStyle: TextStyle(
              color: const Color(0xFFB0B6C6),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w700,
            ),
            defaultTextStyle: TextStyle(
              color: const Color(0xFF060914),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w700,
            ),
            weekendTextStyle: TextStyle(
              color: const Color(0xFF060914),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w700,
            ),
            cellMargin: EdgeInsets.all(context.rs(3)),
            todayDecoration: const BoxDecoration(
              color: Color(0xFFEAE7FF),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: const Color(0xFF635BFF),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w900,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF635BFF),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: Colors.white,
              fontSize: context.rs(14),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
