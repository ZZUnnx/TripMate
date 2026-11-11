import 'package:flutter/material.dart';

import '../../models/home_data.dart';
import '../../models/trip_schedule.dart';
import '../common/responsive.dart';
import 'home_section_header.dart';

class MonthlyScheduleSection extends StatelessWidget {
  const MonthlyScheduleSection({
    super.key,
    required this.data,
    this.onScheduleTap,
    this.onViewCalendar,
  });
  final HomeData data;
  final ValueChanged<TripSchedule>? onScheduleTap;
  final VoidCallback? onViewCalendar;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      HomeSectionHeader(
        title: '이번 달 일정',
        action: '캘린더 보기',
        onAction: onViewCalendar,
      ),
      if (data.monthlySchedules == null || data.monthlySchedules!.isEmpty)
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            data.monthlySchedules == null
                ? '일정을 불러오지 못했어요.'
                : '이번 달 등록된 일정이 없습니다.',
          ),
        ),
      Padding(
        padding: context.symmetricInsets(horizontal: 18),
        child: Column(
          children: [
            for (final schedule
                in data.monthlySchedules ?? <TripSchedule>[]) ...[
              InkWell(
                onTap: onScheduleTap == null
                    ? null
                    : () => onScheduleTap!(schedule),
                child: _ScheduleListItem(
                  month: '${schedule.scheduledDate.month}월',
                  day: '${schedule.scheduledDate.day}',
                  title: schedule.title,
                  detail:
                      '${schedule.tripTitle} · ${schedule.scheduledTime?.substring(0, 5) ?? '시간 미정'}',
                  tag: schedule.category,
                ),
              ),
              const ResponsiveGap(height: 8),
            ],
            const ResponsiveGap(height: 16),
          ],
        ),
      ),
    ],
  );
}

class _ScheduleListItem extends StatelessWidget {
  const _ScheduleListItem({
    required this.month,
    required this.day,
    required this.title,
    required this.detail,
    required this.tag,
  });

  final String month;
  final String day;
  final String title;
  final String detail;
  final String tag;
  final bool blue = false;

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
