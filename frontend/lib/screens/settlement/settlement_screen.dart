import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/settlement/settlement_detail_controller.dart';
import '../../models/settlement.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../widgets/settlement/expense_editor_sheet.dart';
import '../../widgets/settlement/settlement_expense_list.dart';
import '../../widgets/settlement/my_settlement_cards.dart';
import '../../widgets/settlement/settlement_payers_card.dart';
import '../../widgets/settlement/settlement_place_details.dart';
import '../../widgets/settlement/settlement_places_card.dart';
import '../../widgets/settlement/settlement_primary_button.dart';
import '../../widgets/settlement/settlement_result_sheet.dart';
import '../../widgets/settlement/settlement_top_header.dart';
import '../../widgets/settlement/settlement_total_summary.dart';
import '../../widgets/settlement/settlement_view_tabs.dart';

typedef SettlementDetailFactory = SettlementDetailController Function(
  int tripId,
  String token,
);

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({
    super.key,
    required this.tripId,
    this.tripTitle = '여행 정산',
    this.currentIndex = 3,
    this.onNavigationSelected,
    this.controllerFactory,
  });
  final int tripId;
  final String tripTitle;
  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;
  final SettlementDetailFactory? controllerFactory;
  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  SettlementDetailController? _controller;
  String? _token;
  SettlementView _view = SettlementView.overview;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = context.watch<AuthProvider>().accessToken;
    if (_token == token && _controller != null) return;
    _controller?.removeListener(_changed);
    _controller?.dispose();
    _token = token;
    _controller = token == null
        ? null
        : (widget.controllerFactory?.call(widget.tripId, token) ??
              SettlementDetailController(
                tripId: widget.tripId,
                accessToken: token,
              ));
    _controller?.addListener(_changed);
    _controller?.load();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_changed);
    _controller?.dispose();
    super.dispose();
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _edit(SettlementData data, [SettlementExpense? expense]) async {
    final controller = _controller;
    if (controller == null || controller.isBusy || data.members.isEmpty) return;
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    final draft = await showModalBottomSheet<ExpenseDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => ExpenseEditorSheet(
        members: data.members,
        currentUserId: userId,
        expense: expense,
      ),
    );
    if (!mounted || draft == null || controller != _controller) return;
    try {
      if (await controller.saveExpense(draft, expenseId: expense?.id)) {
        _message('지출을 저장했어요.');
      }
    } catch (e) {
      _message('지출을 저장하지 못했습니다. $e');
    }
  }

  Future<void> _delete(SettlementExpense expense) async {
    final controller = _controller;
    if (controller == null || controller.isBusy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지출 삭제'),
        content: Text('“${expense.title}” 지출을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true || controller != _controller) return;
    try {
      if (await controller.deleteExpense(expense.id)) _message('지출을 삭제했어요.');
    } catch (e) {
      _message('지출을 삭제하지 못했습니다. $e');
    }
  }

  void _result(SettlementData data) {
    final controller = _controller;
    if (controller == null || controller.isBusy) return;
    final scale = ResponsiveScope.scaleOf(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      builder: (_) => ResponsiveScope(
        scale: scale,
        child: SettlementResultSheet(
          data: data,
          onComplete: controller.setCompleted,
        ),
      ),
    );
  }

  Future<void> _export(SettlementData data) async {
    String cell(Object value) {
      var text = value.toString();
      if (value is String && RegExp(r'^[=+@\-\t\r]').hasMatch(text)) {
        text = "'$text";
      }
      return '"${text.replaceAll('"', '""')}"';
    }

    final rows = [
      '지출명,금액,결제자,날짜,장소,분담인원',
      for (final e in data.expenses)
        [
          e.title,
          e.amount,
          e.payerNickname,
          e.date.toIso8601String().substring(0, 10),
          e.placeName ?? '',
          e.participantIds.length,
        ].map(cell).join(','),
    ];
    await Clipboard.setData(ClipboardData(text: rows.join('\r\n')));
    _message('지출 내역을 CSV 형식으로 복사했어요.');
  }

  Widget _state(String text, {bool retry = false}) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(text, textAlign: TextAlign.center),
        if (retry)
          TextButton(onPressed: _controller?.load, child: const Text('다시 시도')),
      ],
    ),
  );
  List<Widget> _content(SettlementData data) {
    final busy = _controller!.isBusy;
    return [
      SettlementTotalSummary(data: data),
      const ResponsiveGap(height: 10),
      if (data.expenses.isEmpty)
        _state('아직 등록된 지출이 없어요.\n지출 등록 버튼으로 첫 비용을 추가해보세요.')
      else ...[
        SettlementViewTabs(
          selectedView: _view,
          onChanged: (view) => setState(() => _view = view),
        ),
        const ResponsiveGap(height: 10),
        if (_view != SettlementView.place)
          SettlementPayersCard(
            compact: _view == SettlementView.overview,
            data: data,
          ),
        if (_view != SettlementView.payer) ...[
          const ResponsiveGap(height: 10),
          SettlementPlacesCard(
            compact: _view == SettlementView.overview,
            data: data,
          ),
        ],
        if (_view == SettlementView.place) ...[
          const ResponsiveGap(height: 10),
          SettlementPlaceDetails(data: data),
        ],
        const ResponsiveGap(height: 10),
        MySettlementCards(data: data),
        const ResponsiveGap(height: 10),
        SettlementExpenseList(
          expenses: data.expenses,
          onEdit: (e) => _edit(data, e),
          onDelete: _delete,
          isBusy: busy,
        ),
        const ResponsiveGap(height: 10),
        SettlementPrimaryButton(onTap: busy ? null : () => _result(data)),
      ],
      const ResponsiveGap(height: 12),
      FilledButton.icon(
        onPressed: busy || data.members.isEmpty ? null : () => _edit(data),
        icon: const Icon(Icons.add),
        label: Text(busy ? '저장 중...' : '지출 등록'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF148776),
          foregroundColor: Colors.white,
        ),
      ),
      if (_controller!.isLoading) const LinearProgressIndicator(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = _controller?.data;
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
                        onRefresh: () async {
                          await _controller?.load();
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: context.insetsFromLTRB(18, 8, 18, 88),
                          children: [
                            SettlementTopHeader(
                              title: data?.title ?? widget.tripTitle,
                              subtitle: data == null
                                  ? '여행별 지출과 정산'
                                  : '${data.period} · ${data.status}',
                              onBack: () => Navigator.pop(context),
                              showDownload:
                                  data != null && data.expenses.isNotEmpty,
                              onDownload: data == null
                                  ? null
                                  : () => _export(data),
                            ),
                            const ResponsiveGap(height: 10),
                            if (!auth.isInitialized)
                              const Center(child: CircularProgressIndicator())
                            else if (auth.accessToken == null)
                              _state('로그인 후 정산 내역을 확인할 수 있어요.')
                            else if (data == null &&
                                _controller?.isLoading == true)
                              const Center(child: CircularProgressIndicator())
                            else ...[
                              if (_controller?.error != null)
                                _state(
                                  '정산 내역을 불러오지 못했습니다.\n${_controller!.error}',
                                  retry: true,
                                ),
                              if (data != null) ..._content(data),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: BottomNavigation(
                          currentIndex: widget.currentIndex,
                          onItemSelected: (index) {
                            Navigator.pop(context);
                            widget.onNavigationSelected?.call(index);
                          },
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
