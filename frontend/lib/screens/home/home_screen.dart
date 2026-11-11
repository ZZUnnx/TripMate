import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/home/home_controller.dart';
import '../../models/home_data.dart';
import '../../models/trip.dart';
import '../../models/trip_schedule.dart';
import '../../models/settlement.dart';
import '../../providers/auth_provider.dart';
import '../calendar/trip_calendar_detail_screen.dart';
import '../settlement/settlement_screen.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/home/active_trip_section.dart';
import '../../widgets/home/home_profile_card.dart';
import '../../widgets/home/home_top_header.dart';
import '../../widgets/home/monthly_schedule_section.dart';
import '../../widgets/home/needs_attention_section.dart';
import '../../widgets/home/quick_stats_section.dart';
import '../../widgets/home/upcoming_trips_section.dart';
import '../../widgets/common/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.currentIndex = 0,
    this.onNavigationSelected,
    this.isActive = true,
    this.controller,
    super.key,
  });
  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;
  final bool isActive;
  final HomeController? controller;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _controller = widget.controller ?? HomeController();
  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    _controller.updateSession(
      isInitialized: auth.isInitialized,
      accessToken: auth.accessToken,
      userId: auth.userId,
    );
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _controller.reload();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSchedule(HomeData data, TripSchedule schedule) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripCalendarDetailScreen(
          currentIndex: widget.currentIndex,
          onNavigationSelected: widget.onNavigationSelected,
          schedules: data.schedulesFor(schedule.tripId) ?? [],
          selectedSchedule: schedule,
        ),
      ),
    );
    if (mounted) _controller.reload();
  }

  void _openTrip(HomeData data, Trip trip) {
    final schedule = data.schedulesFor(trip.id)?.firstOrNull;
    if (schedule == null) {
      widget.onNavigationSelected?.call(2);
      return;
    }
    _openSchedule(data, schedule);
  }

  Future<void> _openSettlement(SettlementData settlement) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettlementScreen(
          tripId: settlement.tripId,
          tripTitle: settlement.title,
          currentIndex: widget.currentIndex,
          onNavigationSelected: widget.onNavigationSelected,
        ),
      ),
    );
    if (mounted) _controller.reload();
  }

  List<Widget> _content(
    BuildContext context,
    AsyncSnapshot<HomeData> snapshot,
  ) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isInitialized) {
      return [
        const HomeProfileCard(),
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (!auth.isLoggedIn) {
      return [
        const HomeProfileCard(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('로그인하고 내 여행 보기'),
          ),
        ),
      ];
    }
    if (snapshot.connectionState != ConnectionState.done) {
      return [
        const HomeProfileCard(),
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (snapshot.hasError || snapshot.data == null) {
      return [
        const HomeProfileCard(),
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('홈 정보를 불러오지 못했어요.'),
        ),
        TextButton(onPressed: _controller.reload, child: const Text('다시 시도')),
      ];
    }
    final data = snapshot.data!;
    return [
      HomeProfileCard(
        tripCount: data.trips.length,
        companionCount: data.companionCount,
      ),
      if (data.warnings.isNotEmpty)
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              for (final warning in data.warnings) Text(warning),
              TextButton(
                onPressed: _controller.reload,
                child: const Text('다시 조회'),
              ),
            ],
          ),
        ),
      ActiveTripSection(
        data: data,
        onTap: data.activeTrip == null
            ? null
            : () => _openTrip(data, data.activeTrip!),
        onViewAll: () => widget.onNavigationSelected?.call(1),
      ),
      NeedsAttentionSection(data: data, onSettlementTap: _openSettlement),
      QuickStatsSection(data: data),
      UpcomingTripsSection(
        data: data,
        onTripTap: (trip) => _openTrip(data, trip),
        onViewAll: () => widget.onNavigationSelected?.call(1),
      ),
      MonthlyScheduleSection(
        data: data,
        onScheduleTap: (s) => _openSchedule(data, s),
        onViewCalendar: () => widget.onNavigationSelected?.call(2),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : kDesignWidth;
            return ResponsiveScope(
              scale: width / kDesignWidth,
              child: Center(
                child: SizedBox(
                  width: width,
                  child: Stack(
                    children: [
                      FutureBuilder<HomeData>(
                        future: _controller.homeFuture,
                        builder: (context, snapshot) => RefreshIndicator(
                          onRefresh: _controller.reload,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: context.insetsFromLTRB(0, 0, 0, 86),
                            children: [
                              const HomeTopHeader(),
                              ..._content(context, snapshot),
                            ],
                          ),
                        ),
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
