import 'package:flutter/material.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';
import 'calendar_event.dart';
import 'event_icon_tile.dart';

class DaySchedulePanel extends StatelessWidget {
  const DaySchedulePanel({
    required this.selectedDay,
    required this.onEventTap,
    super.key,
  });

  final DateTime selectedDay;
  final void Function(CalendarEvent event, DateTime day) onEventTap;

  @override
  Widget build(BuildContext context) {
    final events = eventsForDay(selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${selectedDay.month}월 ${selectedDay.day}일 ${weekdayName(selectedDay)}요일',
                style: TextStyle(
                  color: const Color(0xFF060914),
                  fontSize: context.rs(20),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '전체 보기',
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
        ),
        const ResponsiveGap(height: 12),
        if (events.isEmpty)
          const _EmptySchedule()
        else
          Container(
            decoration: cardDecoration(context),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < events.length; index++) ...[
                  _ScheduleEventTile(
                    event: events[index],
                    onTap: () => onEventTap(events[index], selectedDay),
                  ),
                  if (index != events.length - 1) const _ScheduleDivider(),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(76),
      alignment: Alignment.center,
      child: Text(
        '등록된 일정이 없어요.',
        style: TextStyle(
          color: const Color(0xFF9AA1B3),
          fontSize: context.rs(14),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScheduleEventTile extends StatelessWidget {
  const _ScheduleEventTile({required this.event, required this.onTap});

  final CalendarEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: context.symmetricInsets(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              EventIconTile(event: event),
              const ResponsiveGap(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF121827),
                        fontSize: context.rs(14),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const ResponsiveGap(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: const Color(0xFF7C83A0),
                          size: context.rs(13),
                        ),
                        const ResponsiveGap(width: 3),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF7C83A0),
                              fontSize: context.rs(13),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const ResponsiveGap(width: 12),
              Text(
                event.timeLabel,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: event.color,
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleDivider extends StatelessWidget {
  const _ScheduleDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.rs(74)),
      child: const Divider(height: 1, thickness: 1, color: Color(0xFFEDEFF5)),
    );
  }
}
