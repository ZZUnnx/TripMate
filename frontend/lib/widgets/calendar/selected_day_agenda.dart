import 'package:flutter/material.dart';

import 'presentation/calendar_formatters.dart';
import 'presentation/calendar_transformations.dart';
import 'presentation/calendar_view_data.dart';

import 'calendar_empty_agenda_card.dart';

import 'calendar_status_pill.dart';
import '../common/responsive.dart';

class SelectedDayAgenda extends StatelessWidget {
  const SelectedDayAgenda({
    super.key,
    required this.selectedDay,
    required this.agendaItems,
    required this.onAgendaTap,
  });

  final DateTime selectedDay;
  final List<CalendarAgendaItem> agendaItems;
  final ValueChanged<CalendarAgendaItem> onAgendaTap;

  @override
  Widget build(BuildContext context) {
    final agendas = calendarAgendaFor(selectedDay, agendaItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedDay.month}월 ${selectedDay.day}일 일정',
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(15),
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  calendarAgendaSummary(agendas),
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            Text(
              '${agendas.length}개',
              style: TextStyle(
                color: const Color(0xFF8A9895),
                fontSize: context.rs(11),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const ResponsiveGap(height: 9),
        if (agendas.isEmpty)
          const CalendarEmptyAgendaCard()
        else
          ...agendas.map(
            (agenda) => Padding(
              padding: EdgeInsets.only(bottom: context.rs(7)),
              child: _AgendaRow(
                agenda: agenda,
                onTap: () => onAgendaTap(agenda),
              ),
            ),
          ),
      ],
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.agenda, required this.onTap});

  final CalendarAgendaItem agenda;
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
          constraints: BoxConstraints(minHeight: context.rs(62)),
          padding: context.insetsFromLTRB(10, 9, 9, 9),
          child: Row(
            children: [
              Container(
                width: context.rs(4),
                height: context.rs(42),
                decoration: BoxDecoration(
                  color: agenda.color,
                  borderRadius: BorderRadius.circular(context.rs(999)),
                ),
              ),
              const ResponsiveGap(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CalendarStatusPill(
                          label: agenda.category,
                          foreground: agenda.color,
                          background: agenda.categoryBackground,
                        ),
                        const ResponsiveGap(width: 5),
                        Flexible(
                          child: Text(
                            agenda.time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF8A9895),
                              fontSize: context.rs(10),
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const ResponsiveGap(height: 3),
                    Text(
                      agenda.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(12),
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    if (agenda.subtitle != null) ...[
                      const ResponsiveGap(height: 3),
                      Text(
                        agenda.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF60706D),
                          fontSize: context.rs(10),
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const ResponsiveGap(width: 8),
              if (agenda.reservationLabel != null ||
                  agenda.participants != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (agenda.reservationLabel != null)
                      CalendarStatusPill(
                        label: agenda.reservationLabel!,
                        foreground: agenda.reservationColor,
                        background: agenda.reservationBackground,
                      ),
                    if (agenda.participants != null) ...[
                      const ResponsiveGap(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            color: const Color(0xFF0B5F55),
                            size: context.rs(12),
                          ),
                          const ResponsiveGap(width: 3),
                          Text(
                            agenda.participants!,
                            style: TextStyle(
                              color: const Color(0xFF0B5F55),
                              fontSize: context.rs(10),
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF8A9895),
                  size: context.rs(18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
