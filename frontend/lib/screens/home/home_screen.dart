import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/common/responsive.dart';
import '../../widgets/home/ai_briefing_card.dart';
import '../../widgets/home/bottom_navigation.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/recent_updates_section.dart';
import '../../widgets/home/schedule_overview.dart';
import '../../widgets/home/schedule_tabs.dart';
import '../../widgets/home/settlement_section.dart';

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
                              children: const [
                                HomeHeader(),
                                ResponsiveGap(height: 22),
                                AiBriefingCard(),
                                ResponsiveGap(height: 14),
                                ScheduleDivider(),
                                ResponsiveGap(height: 14),
                                ScheduleOverview(),
                                ResponsiveGap(height: 24),
                                SettlementSection(),
                                ResponsiveGap(height: 24),
                                RecentUpdatesSection(),
                              ],
                            ),
                            Positioned(
                              left: context.rs(18),
                              right: context.rs(18),
                              bottom: context.rs(12),
                              child: BottomNavigation(
                                currentIndex: currentIndex,
                                onItemSelected: onNavigationSelected,
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
