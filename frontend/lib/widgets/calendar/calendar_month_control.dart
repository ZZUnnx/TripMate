import 'package:flutter/material.dart';

import 'calendar_circle_button.dart';
import '../common/responsive.dart';

class CalendarMonthControl extends StatelessWidget {
  const CalendarMonthControl({
    super.key,
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CalendarCircleButton(
            icon: Icons.chevron_left_rounded,
            iconSize: 20,
            size: 32,
            onTap: onPrevious,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${focusedMonth.year}년 ${focusedMonth.month}월',
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(18),
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const ResponsiveGap(width: 7),
              Container(
                padding: context.symmetricInsets(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3F2),
                  borderRadius: BorderRadius.circular(context.rs(999)),
                ),
                child: Text(
                  '오늘',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          CalendarCircleButton(
            icon: Icons.chevron_right_rounded,
            iconSize: 20,
            size: 32,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}
