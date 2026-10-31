import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'home_section_header.dart';

class MonthlyScheduleSection extends StatelessWidget {
  const MonthlyScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HomeSectionHeader(title: '이번 달 일정', action: '캘린더 보기'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              _ScheduleListItem(
                month: '4월',
                day: '18',
                title: '김포공항 집결',
                detail: '봄바람 따라, 제주 · 08:20',
                tag: '제주',
              ),
              ResponsiveGap(height: 8),
              _ScheduleListItem(
                month: '4월',
                day: '19',
                title: '우도 해변 투어',
                detail: '봄바람 따라, 제주 · 10:00',
                tag: '제주',
              ),
              ResponsiveGap(height: 8),
              _ScheduleListItem(
                month: '12월',
                day: '24',
                title: '오사카 출발',
                detail: '오사카 겨울 여행 · 미정',
                tag: '오사카',
                blue: true,
              ),
              ResponsiveGap(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleListItem extends StatelessWidget {
  const _ScheduleListItem({
    required this.month,
    required this.day,
    required this.title,
    required this.detail,
    required this.tag,
    this.blue = false,
  });

  final String month;
  final String day;
  final String title;
  final String detail;
  final String tag;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    final color = blue ? const Color(0xFF4E79C7) : const Color(0xFF0B5F55);
    final background = blue ? const Color(0xFFEAF0FB) : const Color(0xFFDDF3EE);

    return Container(
      padding: context.symmetricInsets(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(36),
            height: context.rs(36),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.rs(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: TextStyle(color: color, fontSize: context.rs(9)),
                ),
                Text(
                  day,
                  style: TextStyle(
                    color: color,
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(10),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: context.symmetricInsets(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.rs(999)),
            ),
            child: Text(
              tag,
              style: TextStyle(color: color, fontSize: context.rs(9)),
            ),
          ),
        ],
      ),
    );
  }
}
