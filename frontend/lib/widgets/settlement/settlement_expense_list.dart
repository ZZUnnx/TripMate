import 'package:flutter/material.dart';

import '../../models/settlement.dart';
import '../common/responsive.dart';
import 'settlement_card_components.dart';

class SettlementExpenseList extends StatelessWidget {
  const SettlementExpenseList({
    super.key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
    required this.isBusy,
  });
  final List<SettlementExpense> expenses;
  final ValueChanged<SettlementExpense> onEdit;
  final ValueChanged<SettlementExpense> onDelete;
  final bool isBusy;
  @override
  Widget build(BuildContext context) => SettlementCard(
    child: Column(
      children: [
        SettlementCardHeader(title: '지출 내역', action: '${expenses.length}건'),
        const ResponsiveGap(height: 8),
        for (final expense in expenses)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              expense.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: context.rs(13)),
            ),
            subtitle: Text(
              '${expense.payerNickname} · ${expense.date.month}/${expense.date.day} · ${expense.placeName ?? '장소 미지정'}\n${expense.participantIds.length}명 분담',
              style: TextStyle(
                fontSize: context.rs(10),
                color: const Color(0xFF60706D),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settlementWon(expense.amount),
                  style: TextStyle(
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !isBusy,
                  tooltip: '지출 관리',
                  onSelected: (action) =>
                      action == 'edit' ? onEdit(expense) : onDelete(expense),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('수정')),
                    PopupMenuItem(value: 'delete', child: Text('삭제')),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
