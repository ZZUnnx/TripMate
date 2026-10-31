import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../presentation/calendar_formatters.dart';
import '../presentation/calendar_view_data.dart';

import '../calendar_empty_agenda_card.dart';

import '../../../models/trip_schedule.dart';
import '../calendar_status_pill.dart';
import '../../common/responsive.dart';

class TripTimelineHeading extends StatelessWidget {
  const TripTimelineHeading({super.key, required this.timeRange});

  final String timeRange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '여행 전체 타임라인',
          style: TextStyle(
            color: const Color(0xFF152523),
            fontSize: context.rs(15),
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          timeRange,
          style: TextStyle(
            color: const Color(0xFF8A9895),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class TripTimeline extends StatelessWidget {
  const TripTimeline({super.key, required this.sections});

  final List<CalendarTimelineDateSection> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const CalendarEmptyAgendaCard();
    }

    return Column(
      children: sections
          .map(
            (section) => Padding(
              padding: EdgeInsets.only(bottom: context.rs(12)),
              child: _TimelineSection(section: section),
            ),
          )
          .toList(),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.section});

  final CalendarTimelineDateSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              section.title,
              style: TextStyle(
                color: const Color(0xFF152523),
                fontSize: context.rs(14),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${section.items.length}개 일정',
              style: TextStyle(
                color: const Color(0xFF60706D),
                fontSize: context.rs(10),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const ResponsiveGap(height: 8),
        ...List.generate(section.items.length, (index) {
          return _TimelineRow(
            item: section.items[index],
            isLast: index == section.items.length - 1,
          );
        }),
      ],
    );
  }
}

class _TimelineRow extends StatefulWidget {
  const _TimelineRow({required this.item, required this.isLast});

  final CalendarTripTimelineEntry item;
  final bool isLast;

  @override
  State<_TimelineRow> createState() => _TimelineRowState();
}

class _TimelineRowState extends State<_TimelineRow>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final schedule = item.schedule;
    final memo = schedule.description;
    final url = schedule.url;

    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(5)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.rs(36),
              child: Text(
                item.time,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const ResponsiveGap(width: 7),
            SizedBox(
              width: context.rs(12),
              child: Column(
                children: [
                  Container(
                    width: context.rs(7),
                    height: context.rs(7),
                    margin: EdgeInsets.only(top: context.rs(2)),
                    decoration: BoxDecoration(
                      color: item.dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!widget.isLast)
                    Expanded(
                      child: Container(
                        width: context.rs(2),
                        margin: EdgeInsets.only(top: context.rs(3)),
                        color: const Color(0xFFDCE6E3),
                      ),
                    ),
                ],
              ),
            ),
            const ResponsiveGap(width: 7),
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.rs(12)),
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(context.rs(12)),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: double.infinity,
                      padding: context.symmetricInsets(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFDCE6E3)),
                        borderRadius: BorderRadius.circular(context.rs(12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: _expanded ? 2 : 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF152523),
                                        fontSize: context.rs(12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const ResponsiveGap(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: const Color(0xFF60706D),
                                          size: context.rs(10),
                                        ),
                                        const ResponsiveGap(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.place,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: const Color(0xFF60706D),
                                              fontSize: context.rs(10),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const ResponsiveGap(width: 7),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CalendarStatusPill(
                                    label: item.status.label,
                                    foreground: item.status.foreground,
                                    background: item.status.background,
                                  ),
                                  const ResponsiveGap(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.cost,
                                        style: TextStyle(
                                          color: const Color(0xFF152523),
                                          fontSize: context.rs(10),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const ResponsiveGap(width: 3),
                                      Icon(
                                        _expanded
                                            ? Icons.expand_less_rounded
                                            : Icons.expand_more_rounded,
                                        color: const Color(0xFF8A9895),
                                        size: context.rs(14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            reverseDuration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                alignment: Alignment.topCenter,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _expanded
                                ? _TimelineDetailContent(
                                    key: ValueKey(item.schedule.id),
                                    item: item,
                                    schedule: schedule,
                                    memo: memo,
                                    url: url,
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('collapsed'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineDetailContent extends StatelessWidget {
  const _TimelineDetailContent({
    required super.key,
    required this.item,
    required this.schedule,
    required this.memo,
    required this.url,
  });

  final CalendarTripTimelineEntry item;
  final TripSchedule schedule;
  final String? memo;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveGap(height: 9),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE7EFEC)),
        const ResponsiveGap(height: 9),
        _DetailInfoRow(
          icon: Icons.event_outlined,
          label: '날짜',
          value: calendarFormatFullDate(schedule.scheduledDate),
        ),
        const ResponsiveGap(height: 7),
        _DetailInfoRow(
          icon: Icons.access_time_rounded,
          label: '시간',
          value: calendarFormatScheduleTime(schedule.scheduledTime),
        ),
        const ResponsiveGap(height: 7),
        _DetailInfoRow(
          icon: Icons.location_on_outlined,
          label: '장소',
          value: item.place,
        ),
        if (memo != null && memo!.trim().isNotEmpty) ...[
          const ResponsiveGap(height: 7),
          _DetailInfoRow(
            icon: Icons.notes_rounded,
            label: '메모',
            value: memo!,
            maxLines: 3,
          ),
        ],
        if (url != null && url!.trim().isNotEmpty) ...[
          const ResponsiveGap(height: 7),
          _DetailInfoRow(
            icon: Icons.link_rounded,
            label: '링크',
            value: url!,
            actionIcon: Icons.copy_rounded,
            onAction: () {
              Clipboard.setData(ClipboardData(text: url!));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('링크를 복사했어요.')));
            },
          ),
        ],
      ],
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String label;
  final String value;
  final int maxLines;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF60706D), size: context.rs(14)),
        const ResponsiveGap(width: 7),
        SizedBox(
          width: context.rs(34),
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF8A9895),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
        const ResponsiveGap(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(11),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
        if (actionIcon != null && onAction != null) ...[
          const ResponsiveGap(width: 8),
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(context.rs(999)),
            child: Padding(
              padding: EdgeInsets.all(context.rs(2)),
              child: Icon(
                actionIcon,
                color: const Color(0xFF0B5F55),
                size: context.rs(14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
