import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/common/responsive.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/settlement/my_settlement_cards.dart';
import '../../widgets/settlement/settlement_payers_card.dart';
import '../../widgets/settlement/settlement_place_details.dart';
import '../../widgets/settlement/settlement_places_card.dart';
import '../../widgets/settlement/settlement_primary_button.dart';
import '../../widgets/settlement/settlement_result_sheet.dart';
import '../../widgets/settlement/settlement_top_header.dart';
import '../../widgets/settlement/settlement_total_summary.dart';
import '../../widgets/settlement/settlement_view_tabs.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({
    this.currentIndex = 3,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  SettlementView _selectedView = SettlementView.overview;

  void _showSettlementResult(BuildContext context) {
    final scale = ResponsiveScope.scaleOf(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: const Color(0xFF152523).withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ResponsiveScope(
          scale: scale,
          child: const SettlementResultSheet(),
        );
      },
    );
  }

  List<Widget> _contentForSelectedView() {
    switch (_selectedView) {
      case SettlementView.overview:
        return const [
          SettlementPayersCard(compact: true),
          ResponsiveGap(height: 10),
          SettlementPlacesCard(compact: true),
        ];
      case SettlementView.payer:
        return const [SettlementPayersCard(compact: false)];
      case SettlementView.place:
        return const [
          SettlementPlacesCard(compact: false),
          ResponsiveGap(height: 10),
          SettlementPlaceDetails(),
        ];
    }
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
                            const SettlementTopHeader(),
                            const ResponsiveGap(height: 10),
                            const SettlementTotalSummary(),
                            const ResponsiveGap(height: 10),
                            SettlementViewTabs(
                              selectedView: _selectedView,
                              onChanged: (view) {
                                setState(() => _selectedView = view);
                              },
                            ),
                            const ResponsiveGap(height: 10),
                            ..._contentForSelectedView(),
                            const ResponsiveGap(height: 10),
                            const MySettlementCards(),
                            const ResponsiveGap(height: 10),
                            SettlementPrimaryButton(
                              onTap: () => _showSettlementResult(context),
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
