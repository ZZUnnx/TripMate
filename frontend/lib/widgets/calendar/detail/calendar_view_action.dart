import 'package:flutter/material.dart';

import '../../common/responsive.dart';

class CalendarViewAction extends StatelessWidget {
  const CalendarViewAction({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: Container(
          height: context.rs(43),
          padding: context.symmetricInsets(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCE6E3)),
            borderRadius: BorderRadius.circular(context.rs(12)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: const Color(0xFF0B5F55),
                size: context.rs(15),
              ),
              const ResponsiveGap(width: 8),
              Expanded(
                child: Text(
                  '전체 캘린더에서 보기',
                  style: TextStyle(
                    color: const Color(0xFF0B5F55),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '전체 일정',
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
