import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/settlement/settlement_list_controller.dart';
import '../../models/settlement.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/settlement/settlement_top_header.dart';
import '../../widgets/settlement/settlement_trip_card.dart';
import 'settlement_screen.dart';

class SettlementListScreen extends StatefulWidget {
  const SettlementListScreen({
    super.key,
    this.currentIndex = 3,
    this.onNavigationSelected,
    this.isActive = true,
    this.controller,
    this.detailControllerFactory,
  });
  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;
  final bool isActive;
  final SettlementListController? controller;
  final SettlementDetailFactory? detailControllerFactory;
  @override
  State<SettlementListScreen> createState() => _SettlementListScreenState();
}

class _SettlementListScreenState extends State<SettlementListScreen> {
  late final _controller = widget.controller ?? SettlementListController();
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
    );
  }

  @override
  void didUpdateWidget(covariant SettlementListScreen oldWidget) {
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

  Future<void> _refresh() async {
    _controller.reload();
    try {
      await _controller.tripsFuture;
    } catch (_) {}
  }

  Future<void> _openTrip(SettlementData trip) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettlementScreen(
          tripId: trip.tripId,
          tripTitle: trip.title,
          currentIndex: widget.currentIndex,
          onNavigationSelected: widget.onNavigationSelected,
          controllerFactory: widget.detailControllerFactory,
        ),
      ),
    );
    if (mounted) _controller.reload();
  }

  Widget _state(
    String message, {
    VoidCallback? action,
    String label = '다시 시도',
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        const Icon(
          Icons.receipt_long_outlined,
          color: Color(0xFF148776),
          size: 36,
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        if (action != null) TextButton(onPressed: action, child: Text(label)),
      ],
    ),
  );
  Widget _body(AuthProvider auth) {
    if (!auth.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (auth.accessToken == null) {
      return _state(
        '로그인 후 참여한 여행을 확인할 수 있어요.',
        label: '로그인',
        action: () => Navigator.pushNamed(context, '/login'),
      );
    }
    return FutureBuilder<List<SettlementData>>(
      future: _controller.tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _state(
            '정산 목록을 불러오지 못했습니다.\n${snapshot.error}',
            action: _controller.reload,
          );
        }
        final trips = snapshot.data ?? [];
        if (trips.isEmpty) {
          return _state('아직 참여한 여행이 없어요.\n채팅에서 여행방을 만들거나 초대받아보세요.');
        }
        final pending = trips.where((trip) => !trip.completed).toList();
        final completed = trips.where((trip) => trip.completed).toList();
        return Column(
          children: [
            if (pending.isNotEmpty) _section('정산할 여행', pending),
            if (completed.isNotEmpty) ...[
              const ResponsiveGap(height: 20),
              _section('정산 완료', completed),
            ],
          ],
        );
      },
    );
  }

  Widget _section(String title, List<SettlementData> trips) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${trips.length}개',
            style: const TextStyle(color: Color(0xFF60706D)),
          ),
        ],
      ),
      const ResponsiveGap(height: 10),
      for (final trip in trips) ...[
        SettlementTripCard(trip: trip, onTap: () => _openTrip(trip)),
        const ResponsiveGap(height: 10),
      ],
    ],
  );
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
              final width = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : kDesignWidth;
              return ResponsiveScope(
                scale: width / kDesignWidth,
                child: Builder(
                  builder: (context) => Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: context.insetsFromLTRB(18, 8, 18, 88),
                          children: [
                            const SettlementTopHeader(
                              title: '여행 정산',
                              subtitle: '참여한 여행의 지출과 정산을 한눈에',
                              showDownload: false,
                            ),
                            const ResponsiveGap(height: 18),
                            _body(auth),
                          ],
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
              );
            },
          ),
        ),
      ),
    );
  }
}
