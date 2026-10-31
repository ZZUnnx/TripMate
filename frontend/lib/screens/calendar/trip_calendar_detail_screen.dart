import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/calendar/trip_calendar_detail_controller.dart';

import '../../models/trip_schedule.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/calendar/detail/calendar_view_action.dart';
import '../../widgets/calendar/detail/trip_calendar_header.dart';
import '../../widgets/calendar/detail/trip_cost_summary_card.dart';
import '../../widgets/calendar/detail/trip_map_notice.dart';
import '../../widgets/calendar/detail/trip_overview_card.dart';
import '../../widgets/calendar/detail/trip_timeline.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/common/bottom_navigation.dart';

class TripCalendarDetailScreen extends StatefulWidget {
  const TripCalendarDetailScreen({
    required this.currentIndex,
    required this.onNavigationSelected,
    required this.schedules,
    required this.selectedSchedule,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;
  final List<TripSchedule> schedules;
  final TripSchedule selectedSchedule;

  @override
  State<TripCalendarDetailScreen> createState() =>
      _TripCalendarDetailScreenState();
}

class _TripCalendarDetailScreenState extends State<TripCalendarDetailScreen> {
  late TripCalendarDetailController _controller;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _controller = TripCalendarDetailController(
      schedules: widget.schedules,
      selectedSchedule: widget.selectedSchedule,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.updateSession(context.watch<AuthProvider>().accessToken);
  }

  @override
  void didUpdateWidget(covariant TripCalendarDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedules != widget.schedules ||
        oldWidget.selectedSchedule != widget.selectedSchedule) {
      _createController();
      _controller.updateSession(context.read<AuthProvider>().accessToken);
    }
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == widget.currentIndex) {
      Navigator.of(context).maybePop();
      return;
    }

    Navigator.of(context).pop();
    widget.onNavigationSelected?.call(index);
  }

  void _showPreparingMessage(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label 기능은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final timelineSections = _controller.timelineSections;
    final timeRange = _controller.timeRange;
    final dateRange = _controller.dateRange;
    final membersFuture = _controller.membersFuture;

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
                            TripCalendarHeader(
                              title: widget.selectedSchedule.tripTitle,
                              subtitle: '$dateRange · 여행 전체 타임라인',
                              onBack: () => Navigator.of(context).pop(),
                              onAdd: () =>
                                  _showPreparingMessage(context, '일정 추가'),
                            ),
                            const ResponsiveGap(height: 8),
                            TripOverviewCard(
                              dateRange: dateRange,
                              scheduleCount: widget.schedules.length,
                              destination:
                                  widget.selectedSchedule.tripDestination ??
                                  '여행 일정',
                              membersFuture: membersFuture,
                            ),
                            const ResponsiveGap(height: 8),
                            CalendarViewAction(
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const ResponsiveGap(height: 8),
                            TripCostSummaryCard(
                              totalAmount: 0,
                              participantCount: null,
                            ),
                            const ResponsiveGap(height: 8),
                            TripTimelineHeading(timeRange: timeRange),
                            const ResponsiveGap(height: 8),
                            TripTimeline(sections: timelineSections),
                            const ResponsiveGap(height: 8),
                            TripMapNotice(
                              onTap: () => _showPreparingMessage(context, '지도'),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BottomNavigation(
                            currentIndex: widget.currentIndex,
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
