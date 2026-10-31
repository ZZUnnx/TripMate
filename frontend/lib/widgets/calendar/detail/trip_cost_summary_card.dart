import 'package:flutter/material.dart';

import '../presentation/calendar_formatters.dart';

import '../calendar_muted_text.dart';

import '../../common/responsive.dart';

class TripCostSummaryCard extends StatelessWidget {
  const TripCostSummaryCard({
    super.key,
    required this.totalAmount,
    required this.participantCount,
  });

  final int totalAmount;
  final int? participantCount;

  @override
  Widget build(BuildContext context) {
    final safeParticipantCount =
        participantCount == null || participantCount! <= 0
        ? 1
        : participantCount!;
    final perPersonAmount = totalAmount ~/ safeParticipantCount;

    return Container(
      padding: context.symmetricInsets(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF3EE),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: const Color(0xFF0B5F55),
                size: context.rs(15),
              ),
              const ResponsiveGap(width: 6),
              Text(
                '확정 비용 합계',
                style: TextStyle(
                  color: const Color(0xFF0B5F55),
                  fontSize: context.rs(11),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CalendarMutedText('총액'),
              Text(
                calendarFormatWon(totalAmount),
                style: TextStyle(
                  color: const Color(0xFF0B5F55),
                  fontSize: context.rs(15),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CalendarMutedText('1인 기준'),
              CalendarMutedText(calendarFormatWon(perPersonAmount)),
            ],
          ),
          const ResponsiveGap(height: 8),
          CalendarMutedText(
            totalAmount == 0 ? '연동된 비용이 없어 0원으로 표시됩니다.' : '확정된 비용만 합계에 포함됩니다.',
          ),
        ],
      ),
    );
  }
}
