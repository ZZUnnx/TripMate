import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/common/responsive.dart';
import '../../widgets/home/bottom_navigation.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    this.currentIndex = 2,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(2026, 4);
  DateTime _selectedDay = DateTime(2026, 4, 19);

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _openTripDetail() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _TripCalendarDetailScreen(
          currentIndex: widget.currentIndex,
          onNavigationSelected: widget.onNavigationSelected,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF9),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : kDesignWidth;
              final scale = contentWidth / kDesignWidth;

              return ResponsiveScope(
                scale: scale,
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Stack(
                      children: [
                        ListView(
                          padding: context.insetsFromLTRB(18, 8, 18, 88),
                          children: [
                            const _CalendarHeader(),
                            const ResponsiveGap(height: 14),
                            _MonthControl(
                              focusedMonth: _focusedMonth,
                              onPrevious: () => _changeMonth(-1),
                              onNext: () => _changeMonth(1),
                            ),
                            const ResponsiveGap(height: 10),
                            const _CalendarLegend(),
                            const ResponsiveGap(height: 10),
                            _MonthGrid(
                              focusedMonth: _focusedMonth,
                              selectedDay: _selectedDay,
                              onDaySelected: (day) {
                                setState(() => _selectedDay = day);
                              },
                            ),
                            const ResponsiveGap(height: 10),
                            _SelectedDayAgenda(
                              selectedDay: _selectedDay,
                              onAgendaTap: _openTripDetail,
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BottomNavigation(
                            currentIndex: widget.currentIndex,
                            onItemSelected: widget.onNavigationSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader();

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
                  '개인 일정과 공유 여행을 한눈에',
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
          _CircleIconButton(
            icon: Icons.tune_rounded,
            iconSize: 18,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MonthControl extends StatelessWidget {
  const _MonthControl({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left_rounded,
            iconSize: 20,
            size: 32,
            onTap: onPrevious,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${focusedMonth.year}년 ${focusedMonth.month}월',
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(18),
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const ResponsiveGap(width: 7),
              Container(
                padding: context.symmetricInsets(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3F2),
                  borderRadius: BorderRadius.circular(context.rs(999)),
                ),
                child: Text(
                  '오늘',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          _CircleIconButton(
            icon: Icons.chevron_right_rounded,
            iconSize: 20,
            size: 32,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = _calendarDaysFor(focusedMonth);

    return Container(
      padding: context.insetsFromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: context.rs(21),
            child: Row(
              children: const [
                _WeekdayLabel('일', color: Color(0xFFF27864)),
                _WeekdayLabel('월'),
                _WeekdayLabel('화'),
                _WeekdayLabel('수'),
                _WeekdayLabel('목'),
                _WeekdayLabel('금'),
                _WeekdayLabel('토', color: Color(0xFF4E79C7)),
              ],
            ),
          ),
          ...List.generate(5, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final day = days[weekIndex * 7 + dayIndex];
                return _CalendarDayCell(
                  day: day,
                  isInMonth: day.month == focusedMonth.month,
                  isSelected: _isSameDate(day, selectedDay),
                  markerColors: _markerColorsFor(day),
                  onTap: () => onDaySelected(day),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label, {this.color = const Color(0xFF8A9895)});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isInMonth,
    required this.isSelected,
    required this.markerColors,
    required this.onTap,
  });

  final DateTime day;
  final bool isInMonth;
  final bool isSelected;
  final List<Color> markerColors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? const Color(0xFF0B5F55)
        : isInMonth
        ? const Color(0xFF152523)
        : const Color(0xFF8A9895);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '${day.month}월 ${day.day}일',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(9)),
          child: Container(
            height: context.rs(40),
            padding: EdgeInsets.only(top: context.rs(5)),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFDDF3EE) : Colors.white,
              borderRadius: BorderRadius.circular(context.rs(9)),
            ),
            child: Column(
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const ResponsiveGap(height: 4),
                SizedBox(
                  height: context.rs(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: markerColors
                        .map(
                          (color) => Container(
                            width: context.rs(5),
                            height: context.rs(5),
                            margin: EdgeInsets.symmetric(
                              horizontal: context.rs(1.5),
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDayAgenda extends StatelessWidget {
  const _SelectedDayAgenda({
    required this.selectedDay,
    required this.onAgendaTap,
  });

  final DateTime selectedDay;
  final VoidCallback onAgendaTap;

  @override
  Widget build(BuildContext context) {
    final agendas = _agendaFor(selectedDay);

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
                  _agendaSummary(agendas),
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
          const _EmptyAgendaCard()
        else
          ...agendas.map(
            (agenda) => Padding(
              padding: EdgeInsets.only(bottom: context.rs(7)),
              child: _AgendaRow(agenda: agenda, onTap: onAgendaTap),
            ),
          ),
      ],
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.agenda, required this.onTap});

  final _AgendaItem agenda;
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
                        _StatusPill(
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
                      _StatusPill(
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.rs(999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: context.rs(10),
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _EmptyAgendaCard extends StatelessWidget {
  const _EmptyAgendaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Text(
        '등록된 일정이 없어요.',
        style: TextStyle(
          color: const Color(0xFF60706D),
          fontSize: context.rs(12),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.size = 34,
    this.iconSize = 18,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(999)),
        child: SizedBox(
          width: context.rs(size),
          height: context.rs(size),
          child: Icon(
            icon,
            color: const Color(0xFF152523),
            size: context.rs(iconSize),
          ),
        ),
      ),
    );
  }
}

class _TripCalendarDetailScreen extends StatelessWidget {
  const _TripCalendarDetailScreen({
    required this.currentIndex,
    required this.onNavigationSelected,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) {
      Navigator.of(context).maybePop();
      return;
    }

    Navigator.of(context).pop();
    onNavigationSelected?.call(index);
  }

  void _showPreparingMessage(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label 기능은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF9),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : kDesignWidth;
              final scale = contentWidth / kDesignWidth;

              return ResponsiveScope(
                scale: scale,
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Stack(
                      children: [
                        ListView(
                          padding: context.insetsFromLTRB(18, 5, 18, 88),
                          children: [
                            _TripDetailHeader(
                              onBack: () => Navigator.of(context).pop(),
                              onAdd: () =>
                                  _showPreparingMessage(context, '일정 추가'),
                            ),
                            const ResponsiveGap(height: 8),
                            const _DayOverviewCard(),
                            const ResponsiveGap(height: 8),
                            _CalendarViewAction(
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const ResponsiveGap(height: 8),
                            const _CostSummaryCard(),
                            const ResponsiveGap(height: 8),
                            const _TimelineHeading(),
                            const ResponsiveGap(height: 8),
                            const _TripTimeline(),
                            const ResponsiveGap(height: 8),
                            _MapNotice(
                              onTap: () => _showPreparingMessage(context, '지도'),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BottomNavigation(
                            currentIndex: currentIndex,
                            onItemSelected: (index) =>
                                _handleNavigation(context, index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TripDetailHeader extends StatelessWidget {
  const _TripDetailHeader({required this.onBack, required this.onAdd});

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left_rounded,
            iconSize: 20,
            onTap: onBack,
          ),
          const ResponsiveGap(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제주 봄 여행',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(18),
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  '4월 18일 - 21일 · 여행 전체 타임라인',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          Material(
            color: const Color(0xFF148776),
            borderRadius: BorderRadius.circular(context.rs(999)),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(context.rs(999)),
              child: Padding(
                padding: context.symmetricInsets(horizontal: 11, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: context.rs(13),
                    ),
                    const ResponsiveGap(width: 4),
                    Text(
                      '일정 추가',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rs(10),
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayOverviewCard extends StatelessWidget {
  const _DayOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: context.rs(66)),
      padding: context.symmetricInsets(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4월 18일 - 21일',
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(15),
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const ResponsiveGap(height: 5),
                Row(
                  children: [
                    _StatusPill(
                      label: 'DAY 2',
                      foreground: const Color(0xFF0B5F55),
                      background: const Color(0xFFDDF3EE),
                    ),
                    const ResponsiveGap(width: 5),
                    Flexible(
                      child: Text(
                        '여행 전체 일정 · 4일 12개',
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
          const ResponsiveGap(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: const [
              _ParticipantAvatars(),
              ResponsiveGap(height: 4),
              _TinyMutedText('4명 모두 참여'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParticipantAvatars extends StatelessWidget {
  const _ParticipantAvatars();

  @override
  Widget build(BuildContext context) {
    const avatars = [
      ('민', Color(0xFFDDEEF9)),
      ('서', Color(0xFFFFE8D9)),
      ('준', Color(0xFFE9E1F5)),
      ('나', Color(0xFFDDF3EE)),
    ];

    return SizedBox(
      width: context.rs(83),
      height: context.rs(26),
      child: Stack(
        children: [
          for (var index = 0; index < avatars.length; index++)
            Positioned(
              left: context.rs(index * 19),
              child: Container(
                width: context.rs(26),
                height: context.rs(26),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: avatars[index].$2,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: context.rs(2)),
                ),
                child: Text(
                  avatars[index].$1,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TinyMutedText extends StatelessWidget {
  const _TinyMutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: const Color(0xFF60706D),
        fontSize: context.rs(10),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _CalendarViewAction extends StatelessWidget {
  const _CalendarViewAction({required this.onTap});

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

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF3EE),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: const Color(0xFF0B5F55),
                size: context.rs(15),
              ),
              const ResponsiveGap(width: 6),
              Text(
                '확정 비용 합계',
                style: TextStyle(
                  color: const Color(0xFF0B5F55),
                  fontSize: context.rs(11),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _TinyMutedText('총액'),
              Text(
                '₩142,500',
                style: TextStyle(
                  color: const Color(0xFF0B5F55),
                  fontSize: context.rs(15),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _TinyMutedText('1인 기준'),
              _TinyMutedText('₩35,625'),
            ],
          ),
          const ResponsiveGap(height: 8),
          const _TinyMutedText('금액이 확정된 일정만 합계에 포함됩니다. 비용 미정 7건 제외.'),
        ],
      ),
    );
  }
}

class _TimelineHeading extends StatelessWidget {
  const _TimelineHeading();

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
          '08:30 - 20:00',
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

class _TripTimeline extends StatelessWidget {
  const _TripTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _timelineSections
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

  final _TimelineDateSection section;

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

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.isLast});

  final _TripTimelineEntry item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
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
                  if (!isLast)
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
              child: Container(
                padding: context.symmetricInsets(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDCE6E3)),
                  borderRadius: BorderRadius.circular(context.rs(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF152523),
                              fontSize: context.rs(12),
                              fontWeight: FontWeight.w400,
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
                        _StatusPill(
                          label: item.status.label,
                          foreground: item.status.foreground,
                          background: item.status.background,
                        ),
                        const ResponsiveGap(height: 4),
                        Text(
                          item.cost,
                          style: TextStyle(
                            color: const Color(0xFF152523),
                            fontSize: context.rs(10),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF3F2),
      borderRadius: BorderRadius.circular(context.rs(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(10)),
        child: SizedBox(
          height: context.rs(32),
          child: Padding(
            padding: context.symmetricInsets(horizontal: 11),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  color: const Color(0xFF60706D),
                  size: context.rs(14),
                ),
                const ResponsiveGap(width: 7),
                Text(
                  '지도에서 보기',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const ResponsiveGap(width: 4),
                Text(
                  '· 준비 중',
                  style: TextStyle(
                    color: const Color(0xFF8A9895),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgendaItem {
  const _AgendaItem({
    required this.date,
    required this.category,
    required this.time,
    required this.title,
    required this.color,
    required this.categoryBackground,
    this.subtitle,
    this.reservationLabel,
    this.reservationColor = const Color(0xFFE8A33D),
    this.reservationBackground = const Color(0xFFFFF6DF),
    this.participants,
  });

  final DateTime date;
  final String category;
  final String time;
  final String title;
  final String? subtitle;
  final Color color;
  final Color categoryBackground;
  final String? reservationLabel;
  final Color reservationColor;
  final Color reservationBackground;
  final String? participants;
}

class _TimelineDateSection {
  const _TimelineDateSection({required this.title, required this.items});

  final String title;
  final List<_TripTimelineEntry> items;
}

class _TripTimelineEntry {
  const _TripTimelineEntry({
    required this.time,
    required this.title,
    required this.place,
    required this.status,
    required this.cost,
    required this.dotColor,
  });

  final String time;
  final String title;
  final String place;
  final _TimelineStatus status;
  final String cost;
  final Color dotColor;
}

class _TimelineStatus {
  const _TimelineStatus({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}

const _travelColor = Color(0xFF148776);
const _personalColor = Color(0xFF8067B8);
const _freeColor = Color(0xFF4E79C7);
const _bookingColor = Color(0xFFE8A33D);
const _payColor = Color(0xFF4E79C7);

const _placeConfirmed = _TimelineStatus(
  label: '장소 확정',
  foreground: Color(0xFF2F9D69),
  background: Color(0xFFE5F6EE),
);

const _bookingDone = _TimelineStatus(
  label: '예약 완료',
  foreground: _bookingColor,
  background: Color(0xFFFFF6DF),
);

const _bookingNeeded = _TimelineStatus(
  label: '예약 필요',
  foreground: _bookingColor,
  background: Color(0xFFFFF6DF),
);

const _freeSchedule = _TimelineStatus(
  label: '자유 일정',
  foreground: _freeColor,
  background: Color(0xFFEAF0FB),
);

const _onSitePay = _TimelineStatus(
  label: '현장 결제',
  foreground: _payColor,
  background: Color(0xFFEAF0FB),
);

final List<_TimelineDateSection> _timelineSections = [
  const _TimelineDateSection(
    title: '4월 18일 금요일',
    items: [
      _TripTimelineEntry(
        time: '09:00',
        title: '제주도 도착 · 숙소 체크인',
        place: '제주시 연동',
        status: _placeConfirmed,
        cost: '비용 미정',
        dotColor: _travelColor,
      ),
      _TripTimelineEntry(
        time: '11:30',
        title: '렌터카 픽업',
        place: '제주국제공항 카운터',
        status: _bookingDone,
        cost: '₩65,000',
        dotColor: _bookingColor,
      ),
      _TripTimelineEntry(
        time: '14:00',
        title: '도보 관광 · 저녁 식사',
        place: '제주 시내 · 자유 일정',
        status: _freeSchedule,
        cost: '비용 미정',
        dotColor: _freeColor,
      ),
    ],
  ),
  const _TimelineDateSection(
    title: '4월 19일 토요일',
    items: [
      _TripTimelineEntry(
        time: '08:30',
        title: '성산항 집결',
        place: '성산포항 종합여객터미널',
        status: _placeConfirmed,
        cost: '비용 미정',
        dotColor: _travelColor,
      ),
      _TripTimelineEntry(
        time: '09:00',
        title: '우도행 배 탑승',
        place: '성산 ↔ 우도 왕복',
        status: _bookingNeeded,
        cost: '₩10,500',
        dotColor: _bookingColor,
      ),
      _TripTimelineEntry(
        time: '10:00',
        title: '우도 전기자전거',
        place: '하우목동항 1번 대여소',
        status: _onSitePay,
        cost: '₩20,000',
        dotColor: _freeColor,
      ),
      _TripTimelineEntry(
        time: '12:00',
        title: '온오프 점심',
        place: '우도면 우도해안길 876',
        status: _bookingDone,
        cost: '₩18,000',
        dotColor: Color(0xFFF27864),
      ),
    ],
  ),
  const _TimelineDateSection(
    title: '4월 20일 일요일',
    items: [
      _TripTimelineEntry(
        time: '09:30',
        title: '검멀레 해변 산책',
        place: '우도면 조일리 해안 산책로',
        status: _freeSchedule,
        cost: '비용 미정',
        dotColor: _freeColor,
      ),
      _TripTimelineEntry(
        time: '13:00',
        title: '흑돼지 저녁',
        place: '제주시 조천읍 함덕로',
        status: _bookingNeeded,
        cost: '₩39,500',
        dotColor: _bookingColor,
      ),
      _TripTimelineEntry(
        time: '20:00',
        title: '해변 야경 산책',
        place: '함덕해수욕장',
        status: _freeSchedule,
        cost: '비용 미정',
        dotColor: _travelColor,
      ),
    ],
  ),
  const _TimelineDateSection(
    title: '4월 21일 월요일',
    items: [
      _TripTimelineEntry(
        time: '10:00',
        title: '렌터카 반납',
        place: '제주국제공항 카운터',
        status: _placeConfirmed,
        cost: '비용 미정',
        dotColor: _travelColor,
      ),
      _TripTimelineEntry(
        time: '12:30',
        title: '공항 출국',
        place: '제주국제공항',
        status: _freeSchedule,
        cost: '비용 미정',
        dotColor: _freeColor,
      ),
    ],
  ),
];

final List<_AgendaItem> _agendaItems = [
  _AgendaItem(
    date: DateTime(2026, 4, 2),
    category: '개인',
    time: '18:00',
    title: '여행 준비물 점검',
    color: _personalColor,
    categoryBackground: Color(0xFFF0ECF8),
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 6),
    category: '개인',
    time: '09:00',
    title: '항공권 확인',
    color: _personalColor,
    categoryBackground: Color(0xFFF0ECF8),
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 9),
    category: '개인',
    time: '21:00',
    title: '짐 챙기기',
    color: _personalColor,
    categoryBackground: Color(0xFFF0ECF8),
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 14),
    category: '개인',
    time: '15:00',
    title: '체크인 알림',
    color: _personalColor,
    categoryBackground: Color(0xFFF0ECF8),
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 17),
    category: '공유 여행',
    time: '16:00',
    title: '렌터카 픽업',
    subtitle: '제주 봄 여행 · 제주공항',
    color: _travelColor,
    categoryBackground: Color(0xFFDDF3EE),
    reservationLabel: '예약 완료',
    reservationColor: Color(0xFF2F9D69),
    reservationBackground: Color(0xFFE5F6EE),
    participants: '4명',
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 18),
    category: '공유 여행',
    time: '11:00',
    title: '숙소 체크인',
    subtitle: '제주 봄 여행 · 애월',
    color: _travelColor,
    categoryBackground: Color(0xFFDDF3EE),
    reservationLabel: '예약 완료',
    reservationColor: Color(0xFF2F9D69),
    reservationBackground: Color(0xFFE5F6EE),
    participants: '4명',
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 19),
    category: '공유 여행',
    time: '09:00-10:00',
    title: '우도행 배 탑승',
    subtitle: '제주 봄 여행 · 성산항',
    color: _travelColor,
    categoryBackground: Color(0xFFDDF3EE),
    reservationLabel: '예약 필요',
    participants: '4명',
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 19),
    category: '공유 여행',
    time: '12:00-13:00',
    title: '온오프 점심',
    subtitle: '제주 봄 여행 · 우도해안길 876',
    color: _travelColor,
    categoryBackground: Color(0xFFDDF3EE),
    reservationLabel: '예약 완료',
    reservationColor: Color(0xFF2F9D69),
    reservationBackground: Color(0xFFE5F6EE),
    participants: '4명',
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 19),
    category: '개인',
    time: '20:30',
    title: '엄마 생일 전화하기',
    color: _personalColor,
    categoryBackground: Color(0xFFF0ECF8),
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 20),
    category: '공유 여행',
    time: '10:00',
    title: '오름 산책',
    subtitle: '제주 봄 여행 · 새별오름',
    color: _travelColor,
    categoryBackground: Color(0xFFDDF3EE),
    participants: '4명',
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 21),
    category: '공유 여행',
    time: '14:00',
    title: '카페 투어',
    subtitle: '제주 봄 여행 · 구좌',
    color: _travelColor,
    categoryBackground: Color(0xFFDDF3EE),
    participants: '4명',
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 23),
    category: '개인',
    time: '20:00',
    title: '정산 확인',
    color: _personalColor,
    categoryBackground: Color(0xFFF0ECF8),
  ),
  _AgendaItem(
    date: DateTime(2026, 4, 29),
    category: '개인',
    time: '19:00',
    title: '사진 정리',
    color: _personalColor,
    categoryBackground: Color(0xFFF0ECF8),
  ),
];

List<DateTime> _calendarDaysFor(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final sundayOffset = firstDay.weekday % 7;
  final gridStart = firstDay.subtract(Duration(days: sundayOffset));

  return List.generate(35, (index) => gridStart.add(Duration(days: index)));
}

List<Color> _markerColorsFor(DateTime day) {
  final items = _agendaFor(day);
  final colors = <Color>[];

  if (items.any((item) => item.category == '개인')) {
    colors.add(_personalColor);
  }
  if (items.any((item) => item.category == '공유 여행')) {
    colors.add(_travelColor);
  }

  return colors;
}

List<_AgendaItem> _agendaFor(DateTime day) {
  return _agendaItems
      .where((item) => _isSameDate(item.date, day))
      .toList(growable: false);
}

String _agendaSummary(List<_AgendaItem> agendas) {
  final travelCount = agendas.where((item) => item.category == '공유 여행').length;
  final personalCount = agendas.where((item) => item.category == '개인').length;

  return '공유 여행 $travelCount개 · 개인 $personalCount개';
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
