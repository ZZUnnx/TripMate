import 'package:flutter/material.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';
import '../common/section_header.dart';

// 정산 현황 영역
class SettlementSection extends StatelessWidget {
  const SettlementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SectionHeader(title: '정산 현황', actionLabel: '전체 내역 보기'),
        ResponsiveGap(height: 10),
        Row(
          children: [
            Expanded(
              child: _MoneyCard(
                title: '받을 돈',
                amount: '₩35,000',
                icon: Icons.arrow_downward_rounded,
                iconColor: Color(0xFF45BF74),
                iconBackground: Color(0xFFE2F6EA),
              ),
            ),
            ResponsiveGap(width: 12),
            Expanded(
              child: _MoneyCard(
                title: '보낼 돈',
                amount: '₩12,000',
                icon: Icons.arrow_upward_rounded,
                iconColor: Color(0xFFD84E63),
                iconBackground: Color(0xFFF9E4E8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 받을 돈/보낼 돈 카드
class _MoneyCard extends StatelessWidget {
  const _MoneyCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(82),
      padding: context.symmetricInsets(horizontal: 12),
      decoration: cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: context.rs(46),
            height: context.rs(46),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: context.rs(28)),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF3E4354),
                    fontSize: context.rs(15),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const ResponsiveGap(height: 4),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF060914),
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveIcon(
            Icons.chevron_right_rounded,
            color: Color(0xFF8990A5),
            size: 24,
          ),
        ],
      ),
    );
  }
}
