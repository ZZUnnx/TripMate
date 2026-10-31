import 'package:flutter/material.dart';

import '../../models/settlement.dart';

import '../common/responsive.dart';

class MySettlementCards extends StatelessWidget {
  const MySettlementCards({super.key, required this.data});

  final SettlementData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AmountCard(
            label: '내가 보낼 금액',
            amount: settlementWon(data.completed ? 0 : data.myPayable),
            target: data.completed ? '정산 완료' : '송금할 금액',
            accent: const Color(0xFFF27864),
            background: const Color(0xFFFFF0EC),
          ),
        ),
        const ResponsiveGap(width: 8),
        Expanded(
          child: _AmountCard(
            label: '내가 받을 금액',
            amount: settlementWon(data.completed ? 0 : data.myReceivable),
            target: data.completed ? '정산 완료' : '받아야 할 금액',
            accent: const Color(0xFF2F9D69),
            background: const Color(0xFFE5F6EE),
          ),
        ),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.label,
    required this.amount,
    required this.target,
    required this.accent,
    required this.background,
  });

  final String label;
  final String amount;
  final String target;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 11, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
          const ResponsiveGap(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(18),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const ResponsiveGap(height: 4),
          Text(
            target,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
