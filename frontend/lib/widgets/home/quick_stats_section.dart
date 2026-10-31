import 'package:flutter/material.dart';

import '../common/responsive.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insetsFromLTRB(18, 14, 18, 0),
      child: Row(
        children: const [
          Expanded(
            child: _QuickStatCard(
              icon: Icons.route_outlined,
              label: '다음 일정',
              value: '4/18 08:20',
              detail: '김포공항 집결 · 봄바람 따라 제주',
            ),
          ),
          ResponsiveGap(width: 10),
          Expanded(
            child: _QuickStatCard(
              icon: Icons.account_balance_wallet_outlined,
              label: '전체 정산',
              value: '₩842,600',
              detail: '7건 자동 분류 완료',
              detailColor: Color(0xFF2F9D69),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.detailColor = const Color(0xFF8A9895),
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color detailColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.rs(24),
                height: context.rs(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EC),
                  borderRadius: BorderRadius.circular(context.rs(6)),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFF27864),
                  size: context.rs(13),
                ),
              ),
              const ResponsiveGap(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(11),
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 8),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(15),
              fontWeight: FontWeight.w700,
            ),
          ),
          const ResponsiveGap(height: 8),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: detailColor, fontSize: context.rs(10)),
          ),
        ],
      ),
    );
  }
}
