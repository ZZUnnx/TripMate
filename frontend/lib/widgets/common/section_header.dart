import 'package:flutter/material.dart';

import 'responsive.dart';

// 섹션 제목 영역
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.actionLabel,
    super.key,
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF121827),
            fontSize: context.rs(20),
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const Spacer(),
        Text(
          actionLabel,
          style: TextStyle(
            color: const Color(0xFF9AA1B3),
            fontSize: context.rs(13),
            fontWeight: FontWeight.w700,
          ),
        ),
        const ResponsiveGap(width: 4),
        const ResponsiveIcon(
          Icons.chevron_right_rounded,
          color: Color(0xFF8990A5),
          size: 22,
        ),
      ],
    );
  }
}
