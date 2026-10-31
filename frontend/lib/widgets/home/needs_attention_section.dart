import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'home_section_header.dart';

class NeedsAttentionSection extends StatelessWidget {
  const NeedsAttentionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HomeSectionHeader(title: '확인 필요', action: '3건'),
        _AttentionItem(
          icon: Icons.route_outlined,
          title: '일정 검토 요청',
          meta: '오늘',
          description: '봄바람 따라, 제주 · 2건의 일정 시간이 변경됨',
        ),
        _AttentionItem(
          icon: Icons.account_balance_wallet_outlined,
          title: '미완료 정산 요청',
          meta: '2건',
          description: '오사카 겨울 여행 · 정산 요청이 2일째 미완료',
        ),
        _AttentionItem(
          icon: Icons.calendar_month_outlined,
          title: '예약 마감 또는 변경',
          meta: '1건',
          description: '강릉 당일치기 · 예약 변경 알림이 도착했어요',
        ),
      ],
    );
  }
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
