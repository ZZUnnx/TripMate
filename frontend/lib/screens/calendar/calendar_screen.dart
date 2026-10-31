import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/calendar/presentation/calendar_data.dart';
import '../../controllers/calendar/calendar_controller.dart';
import '../../widgets/calendar/presentation/calendar_view_data.dart';

import '../../models/trip_schedule.dart';
import '../../providers/auth_provider.dart';
import 'trip_calendar_detail_screen.dart';
import '../../widgets/calendar/add_schedule_sheet.dart';
import '../../widgets/calendar/confirm_schedule_deletion.dart';
import '../../widgets/calendar/calendar_legend.dart';
import '../../widgets/calendar/calendar_month_control.dart';
import '../../widgets/calendar/calendar_month_grid.dart';
import '../../widgets/calendar/calendar_state_card.dart';
import '../../widgets/calendar/calendar_top_header.dart';
import '../../widgets/calendar/selected_day_agenda.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/common/bottom_navigation.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    this.currentIndex = 2,
    this.onNavigationSelected,
    this.isActive = true,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;
  final bool isActive;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _controller = CalendarController();
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    _controller.updateSession(
      isInitialized: auth.isInitialized,
      accessToken: auth.accessToken,
    );
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _controller.reload();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _refreshCalendar() => _controller.reload();

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + offset,
      );
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  Future<void> _openTripDetail(
    CalendarAgendaItem agenda,
    List<TripSchedule> schedules,
  ) async {
    final tripSchedules = schedules
        .where((schedule) => schedule.tripId == agenda.schedule.tripId)
        .toList(growable: false);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripCalendarDetailScreen(
          currentIndex: widget.currentIndex,
          onNavigationSelected: widget.onNavigationSelected,
          schedules: tripSchedules,
          selectedSchedule: agenda.schedule,
        ),
      ),
    );
    if (mounted) _controller.reload();
  }

  Future<void> _deleteAgenda(CalendarAgendaItem agenda) async {
    if (_controller.deletingIds.contains(agenda.schedule.id)) return;
    final confirmed = await confirmScheduleDeletion(context, agenda.title);
    if (!confirmed || !mounted) return;
    try {
      final deleted = await _controller.deleteSchedule(agenda.schedule.id);
      if (!mounted || !deleted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('일정을 삭제했어요.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('일정을 삭제하지 못했습니다. $error')));
    }
  }

  Future<void> _openAddScheduleSheet(CalendarData data) async {
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

    final draft = await showModalBottomSheet<CalendarScheduleDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddScheduleSheet(trips: data.trips, initialDate: _selectedDay);
      },
    );

    if (draft == null || !mounted) {
      return;
    }

    try {
      await _controller.addSchedule(draft, accessToken: accessToken);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedDay = draft.scheduledDate;
        _focusedMonth = DateTime(
          draft.scheduledDate.year,
          draft.scheduledDate.month,
        );
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
                        FutureBuilder<CalendarData>(
                          future: _controller.calendarFuture,
                          builder: (context, snapshot) {
                            final data = snapshot.data ?? CalendarData.empty();

                            return ListView(
                              padding: context.insetsFromLTRB(18, 8, 18, 88),
                              children: [
                                CalendarTopHeader(
                                  onAdd: () => _openAddScheduleSheet(data),
                                ),
                                const ResponsiveGap(height: 14),
                                CalendarMonthControl(
                                  focusedMonth: _focusedMonth,
                                  onPrevious: () => _changeMonth(-1),
                                  onNext: () => _changeMonth(1),
                                ),
                                const ResponsiveGap(height: 10),
                                const CalendarLegend(),
                                const ResponsiveGap(height: 10),
                                if (!auth.isInitialized ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting)
                                  const CalendarStateCard(
                                    message: '일정을 불러오는 중이에요.',
                                  )
                                else if (auth.accessToken == null)
                                  const CalendarStateCard(
                                    message: '로그인 후 캘린더를 확인할 수 있어요.',
                                  )
                                else if (snapshot.hasError)
                                  CalendarStateCard(
                                    message: '${snapshot.error}',
                                    actionLabel: '다시 시도',
                                    onAction: _refreshCalendar,
                                  )
                                else ...[
                                  CalendarMonthGrid(
                                    focusedMonth: _focusedMonth,
                                    selectedDay: _selectedDay,
                                    agendaItems: data.agendaItems,
                                    onDaySelected: (day) {
                                      setState(() => _selectedDay = day);
                                    },
                                  ),
                                  const ResponsiveGap(height: 10),
                                  SelectedDayAgenda(
                                    selectedDay: _selectedDay,
                                    agendaItems: data.agendaItems,
                                    onDeleteAgenda: _deleteAgenda,
                                    deletingIds: _controller.deletingIds,
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
