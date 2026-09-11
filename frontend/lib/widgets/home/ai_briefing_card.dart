import 'package:flutter/material.dart';

import '../common/responsive.dart';

// AI 브리핑 카드
class AiBriefingCard extends StatelessWidget {
  const AiBriefingCard({
    this.title = 'AI 여행 브리핑',
    this.destination = '제주도',
    this.daysLeft = 'D-3',
    this.summary = '확정 일정 6개 · 미정산 ₩42,000',
    super.key,
  });

  final String title;
  final String destination;
  final String daysLeft;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(124),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.rs(18)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0EAFE), Color(0xFFE9ECFF), Color(0xFFDAD9FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x12000000),
            blurRadius: context.rs(18),
            offset: Offset(0, context.rs(8)),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: context.rs(16),
            top: context.rs(18),
            child: Container(
              width: context.rs(94),
              height: context.rs(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.rs(40)),
              ),
            ),
          ),
          Positioned(
            right: context.rs(78),
            bottom: context.rs(34),
            child: const ResponsiveIcon(
              Icons.flight_takeoff_rounded,
              color: Color(0xFF83A8F6),
              size: 30,
            ),
          ),
          Positioned(
            right: context.rs(34),
            bottom: 0,
            child: Container(
              width: context.rs(42),
              height: context.rs(58),
              decoration: BoxDecoration(
                color: const Color(0xFF7768F3),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.rs(8)),
                ),
              ),
            ),
          ),
          Positioned(
            right: context.rs(18),
            bottom: 0,
            child: Container(
              width: context.rs(44),
              height: context.rs(44),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F4FF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: context.insetsFromLTRB(18, 18, 86, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ResponsiveIcon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF635BFF),
                      size: 22,
                    ),
                    const ResponsiveGap(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF4C42D8),
                          fontSize: context.rs(17),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const ResponsiveGap(width: 6),
                    const ResponsiveIcon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF635BFF),
                      size: 22,
                    ),
                  ],
                ),
                const Spacer(),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      color: const Color(0xFF101322),
                      fontSize: context.rs(25),
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                    children: [
                      TextSpan(text: '$destination 여행까지 '),
                      TextSpan(
                        text: daysLeft,
                        style: const TextStyle(color: Color(0xFF635BFF)),
                      ),
                    ],
                  ),
                ),
                const ResponsiveGap(height: 12),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF636A80),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w700,
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
