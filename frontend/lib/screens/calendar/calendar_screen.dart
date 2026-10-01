import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../models/trip_schedule.dart';
import '../../providers/auth_provider.dart';
import '../../services/schedule_service.dart';
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
  Future<_CalendarData>? _calendarFuture;
  String? _loadedAccessToken;
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Future<_CalendarData> _loadCalendar(String accessToken) async {
    final trips = await ScheduleService.fetchTrips(accessToken: accessToken);
    final scheduleGroups = await Future.wait(
      trips.map(
        (trip) => ScheduleService.fetchTripSchedules(
          accessToken: accessToken,
          tripId: trip.id,
        ),
      ),
    );
    final schedules = scheduleGroups.expand((items) => items).toList()
      ..sort(_compareTripSchedules);

    return _CalendarData(trips: trips, schedules: schedules);
  }

  void _refreshCalendar() {
    final accessToken = context.read<AuthProvider>().accessToken;

    if (accessToken == null) {
      return;
    }

    setState(() {
      _calendarFuture = _loadCalendar(accessToken);
      _loadedAccessToken = accessToken;
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  void _openTripDetail(_AgendaItem agenda, List<TripSchedule> schedules) {
    final tripSchedules = schedules
        .where((schedule) => schedule.tripId == agenda.schedule.tripId)
        .toList(growable: false);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _TripCalendarDetailScreen(
          currentIndex: widget.currentIndex,
          onNavigationSelected: widget.onNavigationSelected,
          schedules: tripSchedules,
          selectedSchedule: agenda.schedule,
        ),
      ),
    );
  }

  Future<void> _openAddScheduleSheet(_CalendarData data) async {
    final accessToken = context.read<AuthProvider>().accessToken;

    if (accessToken == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    if (data.trips.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('먼저 여행방을 만들어주세요.')));
      return;
    }

    final draft = await showModalBottomSheet<_ScheduleDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddScheduleSheet(trips: data.trips, initialDate: _selectedDay);
      },
    );

    if (draft == null || !mounted) {
      return;
    }

    try {
      await ScheduleService.createScheduleFromInput(
        accessToken: accessToken,
        tripId: draft.tripId,
        title: draft.title,
        scheduledDate: draft.scheduledDate,
        category: draft.category,
        scheduledTime: draft.scheduledTime,
        placeName: draft.placeName,
        url: draft.url,
        description: draft.description,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedDay = draft.scheduledDate;
        _focusedMonth = DateTime(
          draft.scheduledDate.year,
          draft.scheduledDate.month,
        );
        _calendarFuture = _loadCalendar(accessToken);
        _loadedAccessToken = accessToken;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('일정을 추가했어요.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitialized &&
        auth.accessToken != null &&
        (_calendarFuture == null || _loadedAccessToken != auth.accessToken)) {
      _loadedAccessToken = auth.accessToken;
      _calendarFuture = _loadCalendar(auth.accessToken!);
    }

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
                        FutureBuilder<_CalendarData>(
                          future: _calendarFuture,
                          builder: (context, snapshot) {
                            final data = snapshot.data ?? _CalendarData.empty();

                            return ListView(
                              padding: context.insetsFromLTRB(18, 8, 18, 88),
                              children: [
                                _CalendarHeader(
                                  onAdd: () => _openAddScheduleSheet(data),
                                ),
                                const ResponsiveGap(height: 14),
                                _MonthControl(
                                  focusedMonth: _focusedMonth,
                                  onPrevious: () => _changeMonth(-1),
                                  onNext: () => _changeMonth(1),
                                ),
                                const ResponsiveGap(height: 10),
                                const _CalendarLegend(),
                                const ResponsiveGap(height: 10),
                                if (!auth.isInitialized ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting)
                                  const _CalendarStateCard(
                                    message: '일정을 불러오는 중이에요.',
                                  )
                                else if (auth.accessToken == null)
                                  const _CalendarStateCard(
                                    message: '로그인 후 캘린더를 확인할 수 있어요.',
                                  )
                                else if (snapshot.hasError)
                                  _CalendarStateCard(
                                    message: '${snapshot.error}',
                                    actionLabel: '다시 시도',
                                    onAction: _refreshCalendar,
                                  )
                                else ...[
                                  _MonthGrid(
                                    focusedMonth: _focusedMonth,
                                    selectedDay: _selectedDay,
                                    agendaItems: data.agendaItems,
                                    onDaySelected: (day) {
                                      setState(() => _selectedDay = day);
                                    },
                                  ),
                                  const ResponsiveGap(height: 10),
                                  _SelectedDayAgenda(
                                    selectedDay: _selectedDay,
                                    agendaItems: data.agendaItems,
                                    onAgendaTap: (agenda) =>
                                        _openTripDetail(agenda, data.schedules),
                                  ),
                                ],
                              ],
                            );
                          },
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
  const _CalendarHeader({required this.onAdd});

  final VoidCallback onAdd;

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
                  '공유 여행 일정을 한눈에',
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
            icon: Icons.add_rounded,
            iconSize: 18,
            onTap: onAdd,
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
    required this.agendaItems,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<_AgendaItem> agendaItems;
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
                  markerColors: _markerColorsFor(day, agendaItems),
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
    required this.agendaItems,
    required this.onAgendaTap,
  });

  final DateTime selectedDay;
  final List<_AgendaItem> agendaItems;
  final ValueChanged<_AgendaItem> onAgendaTap;

  @override
  Widget build(BuildContext context) {
    final agendas = _agendaFor(selectedDay, agendaItems);

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

class _CalendarStateCard extends StatelessWidget {
  const _CalendarStateCard({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const ResponsiveGap(height: 10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _AddScheduleSheet extends StatefulWidget {
  const _AddScheduleSheet({required this.trips, required this.initialDate});

  final List<Trip> trips;
  final DateTime initialDate;

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _tripId;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay? _scheduledTime;
  String _category = '관광';

  @override
  void initState() {
    super.initState();
    _tripId = widget.trips.first.id;
    _scheduledDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) {
      return;
    }

    setState(() => _scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() => _scheduledTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _tripId == null) {
      return;
    }

    Navigator.of(context).pop(
      _ScheduleDraft(
        tripId: _tripId!,
        title: _titleController.text.trim(),
        category: _category,
        scheduledDate: _scheduledDate,
        scheduledTime: _scheduledTime == null
            ? null
            : _formatTimeOfDay(_scheduledTime!),
        placeName: _nullIfBlank(_placeController.text),
        url: _nullIfBlank(_urlController.text),
        description: _nullIfBlank(_descriptionController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: context.rs(650)),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF9),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(22)),
          ),
        ),
        child: SingleChildScrollView(
          padding: context.insetsFromLTRB(18, 16, 18, 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '일정 추가',
                        style: TextStyle(
                          color: const Color(0xFF152523),
                          fontSize: context.rs(18),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _CircleIconButton(
                      icon: Icons.close_rounded,
                      iconSize: 18,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 14),
                _SheetFieldLabel('여행'),
                DropdownButtonFormField<int>(
                  initialValue: _tripId,
                  items: widget.trips
                      .map(
                        (trip) => DropdownMenuItem<int>(
                          value: trip.id,
                          child: Text(
                            trip.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _tripId = value),
                  decoration: _sheetInputDecoration(context),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('제목'),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _sheetInputDecoration(
                    context,
                    hintText: '예: 해운대 산책',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '일정 제목을 입력해주세요.';
                    }

                    return null;
                  },
                ),
                const ResponsiveGap(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        label: '날짜',
                        value: _formatShortDate(_scheduledDate),
                        icon: Icons.calendar_today_outlined,
                        onTap: _pickDate,
                      ),
                    ),
                    const ResponsiveGap(width: 8),
                    Expanded(
                      child: _PickerField(
                        label: '시간',
                        value: _scheduledTime == null
                            ? '시간 미정'
                            : _formatTimeOfDay(_scheduledTime!),
                        icon: Icons.access_time_rounded,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('카테고리'),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: const ['관광', '식당', '숙소', '교통', '예약', '기타']
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                  decoration: _sheetInputDecoration(context),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('장소'),
                TextFormField(
                  controller: _placeController,
                  textInputAction: TextInputAction.next,
                  decoration: _sheetInputDecoration(
                    context,
                    hintText: '장소명 또는 주소',
                  ),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('링크'),
                TextFormField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: _sheetInputDecoration(
                    context,
                    hintText: 'https://',
                  ),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('메모'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _sheetInputDecoration(context, hintText: '일정 메모'),
                ),
                const ResponsiveGap(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: context.rs(46),
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(Icons.add_rounded, size: context.rs(18)),
                    label: const Text('추가하기'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF148776),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.rs(12)),
                      ),
                    ),
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

class _SheetFieldLabel extends StatelessWidget {
  const _SheetFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(6)),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF60706D),
          fontSize: context.rs(11),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetFieldLabel(label),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.rs(12)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.rs(12)),
            child: Container(
              height: context.rs(48),
              padding: context.symmetricInsets(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDCE6E3)),
                borderRadius: BorderRadius.circular(context.rs(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF0B5F55),
                    size: context.rs(16),
                  ),
                  const ResponsiveGap(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
    required this.schedules,
    required this.selectedSchedule,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;
  final List<TripSchedule> schedules;
  final TripSchedule selectedSchedule;

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
    final timelineSections = _timelineSectionsFromSchedules(schedules);
    final timeRange = _timeRangeFor(schedules);
    final dateRange = _tripDateRange(selectedSchedule);

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
                              title: selectedSchedule.tripTitle,
                              subtitle: '$dateRange · 여행 전체 타임라인',
                              onBack: () => Navigator.of(context).pop(),
                              onAdd: () =>
                                  _showPreparingMessage(context, '일정 추가'),
                            ),
                            const ResponsiveGap(height: 8),
                            _DayOverviewCard(
                              dateRange: dateRange,
                              scheduleCount: schedules.length,
                              destination:
                                  selectedSchedule.tripDestination ?? '여행 일정',
                            ),
                            const ResponsiveGap(height: 8),
                            _CalendarViewAction(
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const ResponsiveGap(height: 8),
                            const _CostSummaryCard(),
                            const ResponsiveGap(height: 8),
                            _TimelineHeading(timeRange: timeRange),
                            const ResponsiveGap(height: 8),
                            _TripTimeline(sections: timelineSections),
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
  const _TripDetailHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
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
                  title,
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
                  subtitle,
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
  const _DayOverviewCard({
    required this.dateRange,
    required this.scheduleCount,
    required this.destination,
  });

  final String dateRange;
  final int scheduleCount;
  final String destination;

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
                  dateRange,
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
                      label: '확정',
                      foreground: const Color(0xFF0B5F55),
                      background: const Color(0xFFDDF3EE),
                    ),
                    const ResponsiveGap(width: 5),
                    Flexible(
                      child: Text(
                        '$destination · 일정 $scheduleCount개',
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
                '일정 정산',
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
                '준비 중',
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
              _TinyMutedText('연결 상태'),
              _TinyMutedText('정산 화면에서 관리'),
            ],
          ),
          const ResponsiveGap(height: 8),
          const _TinyMutedText('확정 일정의 비용 연결은 정산 기능에서 이어집니다.'),
        ],
      ),
    );
  }
}

class _TimelineHeading extends StatelessWidget {
  const _TimelineHeading({required this.timeRange});

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

class _TripTimeline extends StatelessWidget {
  const _TripTimeline({required this.sections});

  final List<_TimelineDateSection> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const _EmptyAgendaCard();
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
  _AgendaItem({
    required this.schedule,
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

  final TripSchedule schedule;
  DateTime get date => schedule.scheduledDate;
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

const _placeConfirmed = _TimelineStatus(
  label: '장소 확정',
  foreground: Color(0xFF2F9D69),
  background: Color(0xFFE5F6EE),
);

const _freeSchedule = _TimelineStatus(
  label: '자유 일정',
  foreground: _freeColor,
  background: Color(0xFFEAF0FB),
);

class _CalendarData {
  _CalendarData({required this.trips, required this.schedules})
    : agendaItems = schedules.map(_agendaItemFromSchedule).toList();

  _CalendarData.empty()
    : trips = const [],
      schedules = const [],
      agendaItems = const [];

  final List<Trip> trips;
  final List<TripSchedule> schedules;
  final List<_AgendaItem> agendaItems;
}

class _ScheduleDraft {
  const _ScheduleDraft({
    required this.tripId,
    required this.title,
    required this.category,
    required this.scheduledDate,
    this.scheduledTime,
    this.placeName,
    this.url,
    this.description,
  });

  final int tripId;
  final String title;
  final String category;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final String? placeName;
  final String? url;
  final String? description;
}

List<DateTime> _calendarDaysFor(DateTime month) {
  final firstDay = DateTime(month.year, month.month);
  final sundayOffset = firstDay.weekday % 7;
  final gridStart = firstDay.subtract(Duration(days: sundayOffset));

  return List.generate(35, (index) => gridStart.add(Duration(days: index)));
}

List<Color> _markerColorsFor(DateTime day, List<_AgendaItem> agendaItems) {
  final items = _agendaFor(day, agendaItems);
  final colors = <Color>[];

  if (items.any((item) => item.category == '개인')) {
    colors.add(_personalColor);
  }
  if (items.any((item) => item.category == '공유 여행')) {
    colors.add(_travelColor);
  }

  return colors;
}

List<_AgendaItem> _agendaFor(DateTime day, List<_AgendaItem> agendaItems) {
  return agendaItems
      .where((item) => _isSameDate(item.date, day))
      .toList(growable: false);
}

String _agendaSummary(List<_AgendaItem> agendas) {
  final travelCount = agendas.where((item) => item.category == '공유 여행').length;
  final personalCount = agendas.where((item) => item.category == '개인').length;

  return '공유 여행 $travelCount개 · 개인 $personalCount개';
}

_AgendaItem _agendaItemFromSchedule(TripSchedule schedule) {
  final category = schedule.category == '개인' ? '개인' : '공유 여행';
  final color = category == '개인' ? _personalColor : _travelColor;
  final place = schedule.placeName ?? schedule.tripDestination;

  return _AgendaItem(
    schedule: schedule,
    category: category,
    time: _formatScheduleTime(schedule.scheduledTime),
    title: schedule.title,
    subtitle: [schedule.tripTitle, ?place].join(' · '),
    color: color,
    categoryBackground: category == '개인'
        ? const Color(0xFFF0ECF8)
        : const Color(0xFFDDF3EE),
    reservationLabel: '확정',
    reservationColor: const Color(0xFF2F9D69),
    reservationBackground: const Color(0xFFE5F6EE),
    participants: category == '공유 여행' ? '공유' : null,
  );
}

List<_TimelineDateSection> _timelineSectionsFromSchedules(
  List<TripSchedule> schedules,
) {
  final grouped = <String, List<TripSchedule>>{};

  for (final schedule in schedules) {
    final key = _dateKey(schedule.scheduledDate);
    grouped.putIfAbsent(key, () => []).add(schedule);
  }

  final dates = grouped.keys.toList()..sort();

  return dates.map((key) {
    final items = grouped[key]!..sort(_compareTripSchedules);
    final date = items.first.scheduledDate;

    return _TimelineDateSection(
      title: _formatFullDate(date),
      items: items.map(_timelineEntryFromSchedule).toList(),
    );
  }).toList();
}

_TripTimelineEntry _timelineEntryFromSchedule(TripSchedule schedule) {
  final category = schedule.category == '개인' ? '개인' : '공유 여행';
  final dotColor = category == '개인' ? _personalColor : _travelColor;

  return _TripTimelineEntry(
    time: _formatScheduleTime(schedule.scheduledTime),
    title: schedule.title,
    place: schedule.placeName ?? schedule.description ?? '장소 미정',
    status: category == '개인' ? _freeSchedule : _placeConfirmed,
    cost: '비용 미정',
    dotColor: dotColor,
  );
}

int _compareTripSchedules(TripSchedule left, TripSchedule right) {
  final dateCompare = left.scheduledDate.compareTo(right.scheduledDate);

  if (dateCompare != 0) {
    return dateCompare;
  }

  final timeCompare = (left.scheduledTime ?? '').compareTo(
    right.scheduledTime ?? '',
  );

  if (timeCompare != 0) {
    return timeCompare;
  }

  final orderCompare = left.sortOrder.compareTo(right.sortOrder);

  if (orderCompare != 0) {
    return orderCompare;
  }

  return left.id.compareTo(right.id);
}

String _timeRangeFor(List<TripSchedule> schedules) {
  final times =
      schedules
          .map((schedule) => schedule.scheduledTime)
          .whereType<String>()
          .toList()
        ..sort();

  if (times.isEmpty) {
    return '시간 미정';
  }

  if (times.length == 1) {
    return _formatScheduleTime(times.first);
  }

  return '${_formatScheduleTime(times.first)} - ${_formatScheduleTime(times.last)}';
}

String _tripDateRange(TripSchedule schedule) {
  final startDate = schedule.tripStartDate;
  final endDate = schedule.tripEndDate;

  if (startDate != null && endDate != null) {
    return '${_formatShortDate(startDate)} - ${_formatShortDate(endDate)}';
  }

  return _formatShortDate(schedule.scheduledDate);
}

String _formatScheduleTime(String? time) {
  if (time == null || time.isEmpty) {
    return '시간 미정';
  }

  final parts = time.split(':');

  if (parts.length >= 2) {
    return '${parts[0]}:${parts[1]}';
  }

  return time;
}

String _formatShortDate(DateTime date) {
  return '${date.month}월 ${date.day}일';
}

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute:00';
}

String _formatFullDate(DateTime date) {
  return '${date.month}월 ${date.day}일 ${_weekdayName(date)}요일';
}

String _weekdayName(DateTime date) {
  return const ['월', '화', '수', '목', '금', '토', '일'][date.weekday - 1];
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}

String? _nullIfBlank(String value) {
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}

InputDecoration _sheetInputDecoration(
  BuildContext context, {
  String? hintText,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF8A9895)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: context.symmetricInsets(horizontal: 12, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFFDCE6E3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFF148776), width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFFF27864)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFFF27864), width: 1.4),
    ),
  );
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
