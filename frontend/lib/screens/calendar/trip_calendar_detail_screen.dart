import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/calendar/presentation/calendar_formatters.dart';
import '../../widgets/calendar/presentation/calendar_transformations.dart';

import '../../models/trip_schedule.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/calendar/detail/calendar_view_action.dart';
import '../../widgets/calendar/detail/trip_calendar_header.dart';
import '../../widgets/calendar/detail/trip_cost_summary_card.dart';
import '../../widgets/calendar/detail/trip_map_notice.dart';
import '../../widgets/calendar/detail/trip_overview_card.dart';
import '../../widgets/calendar/detail/trip_timeline.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/common/bottom_navigation.dart';

class TripCalendarDetailScreen extends StatelessWidget {
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
    final timelineSections = calendarTimelineSectionsFromSchedules(schedules);
    final timeRange = calendarTimeRangeFor(schedules);
    final dateRange = calendarTripDateRange(selectedSchedule);
    final accessToken = context.watch<AuthProvider>().accessToken;
    final membersFuture = accessToken == null
        ? null
        : ChatService.fetchMembers(
            accessToken: accessToken,
            tripId: selectedSchedule.tripId,
          );

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
                              title: selectedSchedule.tripTitle,
                              subtitle: '$dateRange · 여행 전체 타임라인',
                              onBack: () => Navigator.of(context).pop(),
                              onAdd: () =>
                                  _showPreparingMessage(context, '일정 추가'),
                            ),
                            const ResponsiveGap(height: 8),
                            TripOverviewCard(
                              dateRange: dateRange,
                              scheduleCount: schedules.length,
                              destination:
                                  selectedSchedule.tripDestination ?? '여행 일정',
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
