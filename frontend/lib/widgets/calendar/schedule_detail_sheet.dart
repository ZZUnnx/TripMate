import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'calendar_event.dart';
import 'event_icon_tile.dart';

class ScheduleDetailSheet extends StatelessWidget {
  const ScheduleDetailSheet({
    required this.event,
    required this.day,
    super.key,
  });

  final CalendarEvent event;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: context.insetsFromLTRB(24, 10, 24, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(24)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.rs(42),
              height: context.rs(5),
              decoration: BoxDecoration(
                color: const Color(0xFFDADDF0),
                borderRadius: BorderRadius.circular(context.rs(20)),
              ),
            ),
            const ResponsiveGap(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventIconTile(event: event),
                const ResponsiveGap(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: context.rs(8)),
                    child: Text(
                      event.title,
                      style: TextStyle(
                        color: const Color(0xFF060914),
                        fontSize: context.rs(20),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: const Color(0xFFF0F2F7),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: context.rs(36),
                      height: context.rs(36),
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF424969),
                        size: context.rs(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const ResponsiveGap(height: 22),
            _DetailRow(
              icon: Icons.access_time_rounded,
              lines: [
                '${day.year}년 ${day.month}월 ${day.day}일 (${weekdayName(day)})',
                detailTimeLabel(event.timeLabel),
              ],
            ),
            const ResponsiveGap(height: 18),
            _DetailRow(
              icon: Icons.location_on_outlined,
              lines: [event.location],
            ),
            const ResponsiveGap(height: 18),
            const _DetailRow(
              icon: Icons.notes_rounded,
              lines: ['앱 UI 수정사항 정리', '발표 자료 역할 분담'],
            ),
            const ResponsiveGap(height: 18),
            const _DetailRow(
              icon: Icons.notifications_none_rounded,
              lines: ['30분 전 알림'],
            ),
            const ResponsiveGap(height: 26),
            Row(
              children: [
                Expanded(
                  child: _SheetActionButton(
                    label: '삭제',
                    isPrimary: false,
                    onTap: () {},
                  ),
                ),
                const ResponsiveGap(width: 12),
                Expanded(
                  child: _SheetActionButton(
                    label: '수정',
                    isPrimary: true,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.lines});

  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF5F6680), size: context.rs(24)),
        const ResponsiveGap(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in lines)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: context.rs(line == lines.last ? 0 : 5),
                  ),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: const Color(0xFF121827),
                      fontSize: context.rs(14),
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(context.rs(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(10)),
        child: Ink(
          height: context.rs(54),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF7468FF), Color(0xFF9F77F2)],
                  )
                : null,
            border: Border.all(color: const Color(0xFFCFC6FF)),
            borderRadius: BorderRadius.circular(context.rs(10)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : const Color(0xFF635BFF),
                fontSize: context.rs(15),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
