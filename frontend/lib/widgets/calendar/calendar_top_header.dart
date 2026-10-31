import 'package:flutter/material.dart';

import 'calendar_circle_button.dart';
import '../common/responsive.dart';

class CalendarTopHeader extends StatelessWidget {
  const CalendarTopHeader({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Row(
        children: [
          Container(
            width: context.rs(30),
            height: context.rs(30),
            decoration: BoxDecoration(
              color: const Color(0xFF148776),
              borderRadius: BorderRadius.circular(context.rs(10)),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: context.rs(17),
            ),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '통합 캘린더',
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(18),
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  '공유 여행 일정을 한눈에',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          CalendarCircleButton(
            icon: Icons.add_rounded,
            iconSize: 18,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}
