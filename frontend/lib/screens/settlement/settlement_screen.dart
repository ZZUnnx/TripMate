import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/common/responsive.dart';
import '../../widgets/home/bottom_navigation.dart';
import '../../widgets/settlement/expense_history_section.dart';
import '../../widgets/settlement/participant_settlement_section.dart';
import '../../widgets/settlement/settlement_header.dart';
import '../../widgets/settlement/settlement_result_sheet.dart';
import '../../widgets/settlement/trip_selector.dart';
import '../../widgets/settlement/trip_summary_card.dart';

class SettlementScreen extends StatelessWidget {
  const SettlementScreen({
    this.currentIndex = 3,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  void _showSettlementResult(BuildContext context) {
    final scale = ResponsiveScope.scaleOf(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ResponsiveScope(
          scale: scale,
          child: const SettlementResultSheet(),
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
                                const SettlementHeader(),
                                const ResponsiveGap(height: 20),
                                const TripSelector(),
                                const ResponsiveGap(height: 20),
                                TripSummaryCard(
                                  onReceiveTap: () =>
                                      _showSettlementResult(context),
                                ),
                                const ResponsiveGap(height: 26),
                                const ParticipantSettlementSection(),
                                const ResponsiveGap(height: 26),
                                const ExpenseHistorySection(),
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
