import 'package:flutter/material.dart';

import '../../models/home_data.dart';
import '../../models/settlement.dart';
import '../common/responsive.dart';
import 'home_section_header.dart';

class NeedsAttentionSection extends StatelessWidget {
  const NeedsAttentionSection({
    super.key,
    required this.data,
    this.onSettlementTap,
  });
  final HomeData data;
  final ValueChanged<SettlementData>? onSettlementTap;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      HomeSectionHeader(
        title: '확인 필요',
        action: data.needsAttention == null
            ? '조회 실패'
            : '${data.needsAttention!.length}건',
      ),
      if (data.needsAttention == null || data.needsAttention!.isEmpty)
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            data.needsAttention == null
                ? '정산 정보를 불러오지 못했어요.'
                : '확인할 미완료 정산이 없습니다.',
          ),
        ),
      for (final settlement in data.needsAttention ?? <SettlementData>[])
        InkWell(
          onTap: onSettlementTap == null
              ? null
              : () => onSettlementTap!(settlement),
          child: _AttentionItem(
            icon: Icons.account_balance_wallet_outlined,
            title: '미완료 정산',
            meta: '${settlement.expenseCount}건',
            description:
                '${settlement.title} · 총 ${settlementWon(settlement.totalAmount)}',
          ),
        ),
    ],
  );
}

class _AttentionItem extends StatelessWidget {
  const _AttentionItem({
    required this.icon,
    required this.title,
    required this.meta,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String meta;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.insetsFromLTRB(18, 10, 18, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F5F4))),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(36),
            height: context.rs(36),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F4),
              borderRadius: BorderRadius.circular(context.rs(10)),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF27864),
              size: context.rs(17),
            ),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      meta,
                      style: TextStyle(
                        color: const Color(0xFFF27864),
                        fontSize: context.rs(11),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 3),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
