import 'package:flutter/material.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';
import 'section_title.dart';

class ExpenseHistorySection extends StatelessWidget {
  const ExpenseHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SettlementSectionTitle(title: '지출 내역', actionLabel: '최신순'),
        ResponsiveGap(height: 12),
        _ExpenseList(),
      ],
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        children: [
          _ExpenseItem(
            title: '흑돼지 식당',
            meta: '9. 12 (금) 12:30  |  참여자 4명',
            payer: '결제자: 준영',
            amount: '₩84,000',
            icon: Icons.restaurant_rounded,
            color: Color(0xFFF05A7A),
            backgroundColor: Color(0xFFFFE5EC),
          ),
          _ListDivider(),
          _ExpenseItem(
            title: '렌터카',
            meta: '9. 12 (금) 15:00  |  참여자 4명',
            payer: '결제자: 민수',
            amount: '₩70,000',
            tag: 'AI 요약 등록',
            icon: Icons.directions_car_rounded,
            color: Color(0xFF7A67FF),
            backgroundColor: Color(0xFFECE8FF),
          ),
          _ListDivider(),
          _ExpenseItem(
            title: '카페',
            meta: '9. 13 (토) 10:20  |  참여자 3명',
            payer: '결제자: 서연',
            amount: '₩32,000',
            icon: Icons.local_cafe_rounded,
            color: Color(0xFF45B878),
            backgroundColor: Color(0xFFE1F5EA),
          ),
        ],
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  const _ExpenseItem({
    required this.title,
    required this.meta,
    required this.payer,
    required this.amount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.tag,
  });

  final String title;
  final String meta;
  final String payer;
  final String amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.symmetricInsets(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: context.rs(42),
            height: context.rs(42),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(context.rs(10)),
            ),
            child: Icon(icon, color: color, size: context.rs(24)),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF121827),
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const ResponsiveGap(height: 5),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF76809A),
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const ResponsiveGap(height: 4),
                Text(
                  payer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF76809A),
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: const Color(0xFF060914),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (tag != null) ...[
                const ResponsiveGap(height: 8),
                Container(
                  padding: context.symmetricInsets(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE8FF),
                    borderRadius: BorderRadius.circular(context.rs(8)),
                  ),
                  child: Text(
                    tag!,
                    style: TextStyle(
                      color: const Color(0xFF635BFF),
                      fontSize: context.rs(10),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const ResponsiveGap(width: 8),
          const ResponsiveIcon(
            Icons.chevron_right_rounded,
            color: Color(0xFF8990A5),
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _ListDivider extends StatelessWidget {
  const _ListDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.rs(66)),
      child: const Divider(height: 1, thickness: 1, color: Color(0xFFEDEFF5)),
    );
  }
}
