import 'package:flutter/material.dart';

import '../common/responsive.dart';

class MySettlementCards extends StatelessWidget {
  const MySettlementCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _AmountCard(
            label: '내가 보낼 금액',
            amount: '₩92,450',
            target: '민지에게',
            accent: Color(0xFFF27864),
            background: Color(0xFFFFF0EC),
          ),
        ),
        ResponsiveGap(width: 8),
        Expanded(
          child: _AmountCard(
            label: '내가 받을 금액',
            amount: '₩36,900',
            target: '서준에게',
            accent: Color(0xFF2F9D69),
            background: Color(0xFFE5F6EE),
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
