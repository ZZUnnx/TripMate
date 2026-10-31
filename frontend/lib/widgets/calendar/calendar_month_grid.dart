import 'package:flutter/material.dart';

import 'presentation/calendar_transformations.dart';
import 'presentation/calendar_view_data.dart';

import '../common/responsive.dart';

class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.agendaItems,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<CalendarAgendaItem> agendaItems;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = calendarDaysFor(focusedMonth);

    return Container(
      padding: context.insetsFromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: context.rs(21),
            child: Row(
              children: const [
                _WeekdayLabel('일', color: Color(0xFFF27864)),
                _WeekdayLabel('월'),
                _WeekdayLabel('화'),
                _WeekdayLabel('수'),
                _WeekdayLabel('목'),
                _WeekdayLabel('금'),
                _WeekdayLabel('토', color: Color(0xFF4E79C7)),
              ],
            ),
          ),
          ...List.generate(5, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final day = days[weekIndex * 7 + dayIndex];
                return _CalendarDayCell(
                  day: day,
                  isInMonth: day.month == focusedMonth.month,
                  isSelected: calendarIsSameDate(day, selectedDay),
                  markerColors: calendarMarkerColorsFor(day, agendaItems),
                  onTap: () => onDaySelected(day),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label, {this.color = const Color(0xFF8A9895)});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isInMonth,
    required this.isSelected,
    required this.markerColors,
    required this.onTap,
  });

  final DateTime day;
  final bool isInMonth;
  final bool isSelected;
  final List<Color> markerColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? const Color(0xFF0B5F55)
        : isInMonth
        ? const Color(0xFF152523)
        : const Color(0xFF8A9895);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${day.month}월 ${day.day}일',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(9)),
          child: Container(
            height: context.rs(40),
            padding: EdgeInsets.only(top: context.rs(5)),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFDDF3EE) : Colors.white,
              borderRadius: BorderRadius.circular(context.rs(9)),
            ),
            child: Column(
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const ResponsiveGap(height: 4),
                SizedBox(
                  height: context.rs(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: markerColors
                        .map(
                          (color) => Container(
                            width: context.rs(5),
                            height: context.rs(5),
                            margin: EdgeInsets.symmetric(
                              horizontal: context.rs(1.5),
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
