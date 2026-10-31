import 'package:flutter/material.dart';

import '../../models/settlement.dart';
import '../common/responsive.dart';

class SettlementResultSheet extends StatefulWidget {
  const SettlementResultSheet({
    super.key,
    required this.data,
    required this.onComplete,
  });
  final SettlementData data;
  final Future<bool> Function(bool completed) onComplete;
  @override
  State<SettlementResultSheet> createState() => _SettlementResultSheetState();
}

class _SettlementResultSheetState extends State<SettlementResultSheet> {
  bool _saving = false;
  String? _error;
  Future<void> _complete() async {
    if (_saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.data.completed ? '정산 다시 열기' : '정산 완료 확인'),
        content: Text(
          widget.data.completed
              ? '정산 진행 중 상태로 변경할까요?'
              : '실제 송금이 모두 끝났나요?\n이 버튼은 송금하지 않고 완료 상태만 저장합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await widget.onComplete(!widget.data.completed);
      if (mounted && saved) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: SafeArea(
      child: SingleChildScrollView(
        padding: context.symmetricInsets(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '최종 정산 결과',
                    style: TextStyle(
                      fontSize: context.rs(20),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              widget.data.title,
              style: const TextStyle(color: Color(0xFF60706D)),
            ),
            const ResponsiveGap(height: 16),
            if (widget.data.transfers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('추가 송금 없이 정산할 수 있어요.'),
              ),
            for (final transfer in widget.data.transfers)
              Padding(
                padding: context.symmetricInsets(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${transfer.fromNickname} → ${transfer.toNickname}',
                        style: TextStyle(fontSize: context.rs(13)),
                      ),
                    ),
                    Text(
                      settlementWon(transfer.amount),
                      style: TextStyle(
                        fontSize: context.rs(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const ResponsiveGap(height: 12),
            const Text(
              '지출별로 선택한 참여자끼리 균등 분담합니다.\n1원 단위 나머지는 사용자 ID 순서로 배분합니다.',
              style: TextStyle(color: Color(0xFF60706D), fontSize: 12),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const ResponsiveGap(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _complete,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF148776),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _saving
                      ? '저장 중...'
                      : (widget.data.completed ? '정산 다시 열기' : '정산 완료로 표시'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
