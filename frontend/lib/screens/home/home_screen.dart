import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/common/responsive.dart';
import '../../widgets/home/active_trip_section.dart';
import '../../widgets/home/home_profile_card.dart';
import '../../widgets/home/home_top_header.dart';
import '../../widgets/home/monthly_schedule_section.dart';
import '../../widgets/home/needs_attention_section.dart';
import '../../widgets/home/quick_stats_section.dart';
import '../../widgets/home/upcoming_trips_section.dart';
import '../../widgets/common/bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.currentIndex = 0,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

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
                          padding: context.insetsFromLTRB(0, 0, 0, 86),
                          children: const [
                            HomeTopHeader(),
                            HomeProfileCard(),
                            ActiveTripSection(),
                            NeedsAttentionSection(),
                            QuickStatsSection(),
                            UpcomingTripsSection(),
                            MonthlyScheduleSection(),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BottomNavigation(
                            currentIndex: currentIndex,
                            onItemSelected: onNavigationSelected,
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
