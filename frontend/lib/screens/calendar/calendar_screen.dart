import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/calendar/presentation/calendar_data.dart';
import '../../widgets/calendar/presentation/calendar_transformations.dart';
import '../../widgets/calendar/presentation/calendar_view_data.dart';

import '../../models/trip_schedule.dart';
import '../../providers/auth_provider.dart';
import 'trip_calendar_detail_screen.dart';
import '../../services/schedule_service.dart';
import '../../widgets/calendar/add_schedule_sheet.dart';
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
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Future<CalendarData>? _calendarFuture;
  String? _loadedAccessToken;
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Future<CalendarData> _loadCalendar(String accessToken) async {
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
      ..sort(calendarCompareTripSchedules);

    return CalendarData(trips: trips, schedules: schedules);
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

  void _openTripDetail(
    CalendarAgendaItem agenda,
    List<TripSchedule> schedules,
  ) {
    final tripSchedules = schedules
        .where((schedule) => schedule.tripId == agenda.schedule.tripId)
        .toList(growable: false);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripCalendarDetailScreen(
          currentIndex: widget.currentIndex,
          onNavigationSelected: widget.onNavigationSelected,
          schedules: tripSchedules,
          selectedSchedule: agenda.schedule,
        ),
      ),
    );
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
                        FutureBuilder<CalendarData>(
                          future: _calendarFuture,
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
