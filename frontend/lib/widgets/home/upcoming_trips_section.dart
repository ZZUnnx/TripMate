import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'home_section_header.dart';

class UpcomingTripsSection extends StatelessWidget {
  const UpcomingTripsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HomeSectionHeader(title: '예정된 여행', action: '+ 새 여행'),
        _TripListItem(
          emoji: '🏯',
          emojiBackground: Color(0xFF4E79C7),
          title: '오사카 겨울 여행',
          status: '계획 중',
          trailing: 'D-78',
          description: '12월 예정 · 4명과 함께',
          statusColor: Color(0xFF4E79C7),
          statusBackground: Color(0xFFEAF0FB),
        ),
        _TripListItem(
          emoji: '🌊',
          emojiBackground: Color(0xFFE9E1F5),
          title: '강릉 당일치기',
          status: '완료',
          trailing: '3월 2일',
          description: '✓ 정산 완료',
          muted: true,
        ),
      ],
    );
  }
}

class _TripListItem extends StatelessWidget {
  const _TripListItem({
    required this.emoji,
    required this.emojiBackground,
    required this.title,
    required this.status,
    required this.trailing,
    required this.description,
    this.statusColor = const Color(0xFF8A9895),
    this.statusBackground = const Color(0xFFF0F5F4),
    this.muted = false,
  });

  final String emoji;
  final Color emojiBackground;
  final String title;
  final String status;
  final String trailing;
  final String description;
  final Color statusColor;
  final Color statusBackground;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.insetsFromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF7FAF9) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFF0F5F4))),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(46),
            height: context.rs(46),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: emojiBackground,
              borderRadius: BorderRadius.circular(context.rs(14)),
            ),
            child: Text(emoji, style: TextStyle(fontSize: context.rs(20))),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: muted
                              ? const Color(0xFF8A9895)
                              : const Color(0xFF152523),
                          fontSize: context.rs(14),
                          fontWeight: muted ? FontWeight.w600 : FontWeight.w700,
                        ),
                      ),
                    ),
                    const ResponsiveGap(width: 6),
                    Container(
                      padding: context.symmetricInsets(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(context.rs(999)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: context.rs(9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      trailing,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: context.rs(11),
                        fontWeight: muted ? FontWeight.w400 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: muted
                        ? const Color(0xFF2F9D69)
                        : const Color(0xFF60706D),
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
