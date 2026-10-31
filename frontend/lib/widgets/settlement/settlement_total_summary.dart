import 'package:flutter/material.dart';

import '../../models/settlement.dart';

import '../common/responsive.dart';
import 'settlement_card_components.dart';

class SettlementTotalSummary extends StatelessWidget {
  const SettlementTotalSummary({super.key, required this.data});

  final SettlementData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF0B5F55),
        borderRadius: BorderRadius.circular(context.rs(16)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C5547).withValues(alpha: 0.12),
            blurRadius: context.rs(22),
            offset: Offset(0, context.rs(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: const Color(0xFFBEECE3),
                    size: context.rs(15),
                  ),
                  const ResponsiveGap(width: 6),
                  Text(
                    '총지출 · ${data.expenseCount}건',
                    style: TextStyle(
                      color: const Color(0xFFBEECE3),
                      fontSize: context.rs(11),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SettlementPill(
                label: data.status,
                foreground: Color(0xFF2F9D69),
                background: Color(0xFFE5F6EE),
              ),
            ],
          ),
          const ResponsiveGap(height: 10),
          Text(
            settlementWon(data.totalAmount),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rs(26),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const ResponsiveGap(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryFact(
                  label: '1인 평균',
                  value: settlementWon(
                    data.totalAmount ~/
                        (data.expenses
                            .expand((e) => e.participantIds)
                            .toSet()
                            .length
                            .clamp(1, 1000000)),
                  ),
                ),
              ),
              const ResponsiveGap(width: 8),
              Expanded(
                child: _SummaryFact(
                  label: '정산 대상',
                  value:
                      '${data.expenses.expand((e) => e.participantIds).toSet().length}명 · ${data.expenseCount}건',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryFact extends StatelessWidget {
  const _SummaryFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.rs(9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.66),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
          const ResponsiveGap(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rs(12),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
