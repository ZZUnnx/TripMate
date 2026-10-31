import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'presentation/settlement_sample_data.dart';
import 'settlement_card_components.dart';

class SettlementPayersCard extends StatelessWidget {
  const SettlementPayersCard({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final payers = compact
        ? sampleSettlementPayers.take(3).toList()
        : sampleSettlementPayers;

    return SettlementCard(
      child: Column(
        children: [
          const SettlementCardHeader(title: '결제자별 내역', action: '전체 4명'),
          const ResponsiveGap(height: 9),
          ...List.generate(payers.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: context.rs(index == payers.length - 1 ? 0 : 9),
              ),
              child: _PayerRow(payer: payers[index], compact: compact),
            );
          }),
        ],
      ),
    );
  }
}

class _PayerRow extends StatelessWidget {
  const _PayerRow({required this.payer, required this.compact});

  final SettlementPayerData payer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SettlementAvatar(
          initial: payer.initial,
          color: payer.avatarColor,
          size: 28,
          fontSize: 10,
        ),
        const ResponsiveGap(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payer.name,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const ResponsiveGap(height: 2),
              Text(
                compact ? payer.overviewDetail : payer.payerDetail,
                style: TextStyle(
                  color: const Color(0xFF8A9895),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: context.rs(compact ? 66 : 72),
          child: Text(
            payer.amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
