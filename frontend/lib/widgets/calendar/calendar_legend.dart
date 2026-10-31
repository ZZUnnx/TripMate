import 'package:flutter/material.dart';

import '../common/responsive.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendItem(color: Color(0xFF8067B8), label: '개인 일정'),
        ResponsiveGap(width: 14),
        _LegendItem(color: Color(0xFF148776), label: '여행 공유 일정'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: context.rs(7),
          height: context.rs(7),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const ResponsiveGap(width: 5),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF60706D),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
