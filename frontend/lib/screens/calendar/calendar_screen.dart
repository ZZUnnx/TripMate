import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/calendar/calendar_event.dart';
import '../../widgets/calendar/calendar_header.dart';
import '../../widgets/calendar/day_schedule_panel.dart';
import '../../widgets/calendar/month_calendar.dart';
import '../../widgets/calendar/schedule_detail_sheet.dart';
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
  DateTime _focusedDay = DateTime.utc(2024, 9);
  DateTime _selectedDay = DateTime.utc(2024, 9, 13);

  void _showScheduleDetail(CalendarEvent event, DateTime day) {
    final scale = ResponsiveScope.scaleOf(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ResponsiveScope(
          scale: scale,
          child: ScheduleDetailSheet(event: event, day: day),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : kDesignWidth;
              final scale = contentWidth / kDesignWidth;

              return ResponsiveScope(
                scale: scale,
                child: Builder(
                  builder: (context) {
                    return Center(
                      child: SizedBox(
                        width: contentWidth,
                        child: Stack(
                          children: [
                            ListView(
                              padding: context.insetsFromLTRB(22, 24, 22, 118),
                              children: [
                                const CalendarHeader(),
                                const ResponsiveGap(height: 30),
                                MonthCalendar(
                                  focusedDay: _focusedDay,
                                  selectedDay: _selectedDay,
                                  onFocusedDayChanged: (day) {
                                    setState(() {
                                      _focusedDay = day;
                                    });
                                  },
                                  onSelectedDayChanged:
                                      (selectedDay, focusedDay) {
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                        });
                                      },
                                ),
                                const ResponsiveGap(height: 20),
                                DaySchedulePanel(
                                  selectedDay: _selectedDay,
                                  onEventTap: _showScheduleDetail,
                                ),
                              ],
                            ),
                            Positioned(
                              left: context.rs(18),
                              right: context.rs(18),
                              bottom: context.rs(12),
                              child: BottomNavigation(
                                currentIndex: widget.currentIndex,
                                onItemSelected: widget.onNavigationSelected,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
