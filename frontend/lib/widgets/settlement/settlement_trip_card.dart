import 'package:flutter/material.dart';

import '../common/responsive.dart';
import '../../models/settlement.dart';

class SettlementTripCard extends StatelessWidget {
  const SettlementTripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  final SettlementData trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = trip.expenseCount == 0;
    final statusColor = trip.completed
        ? const Color(0xFF2F9D69)
        : (isEmpty ? const Color(0xFF60706D) : const Color(0xFFF27864));
    final statusBackground = trip.completed
        ? const Color(0xFFE5F6EE)
        : (isEmpty ? const Color(0xFFF0F5F4) : const Color(0xFFFFF0EC));

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(14)),
        child: Container(
          padding: context.symmetricInsets(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCE6E3)),
            borderRadius: BorderRadius.circular(context.rs(14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: context.rs(42),
                    height: context.rs(42),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF3EE),
                      borderRadius: BorderRadius.circular(context.rs(12)),
                    ),
                    child: Icon(
                      trip.completed
                          ? Icons.task_alt_rounded
                          : Icons.luggage_outlined,
                      color: const Color(0xFF0B5F55),
                      size: context.rs(22),
                    ),
                  ),
                  const ResponsiveGap(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF152523),
                            fontSize: context.rs(15),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const ResponsiveGap(height: 5),
                        Text(
                          trip.period,
                          style: TextStyle(
                            color: const Color(0xFF60706D),
                            fontSize: context.rs(11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ResponsiveGap(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF8A9895),
                    size: context.rs(20),
                  ),
                ],
              ),
              const ResponsiveGap(height: 14),
              const Divider(height: 1, color: Color(0xFFF0F5F4)),
              const ResponsiveGap(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${trip.members.length}명 참여 · 지출 ${trip.expenseCount}건',
                      style: TextStyle(
                        color: const Color(0xFF60706D),
                        fontSize: context.rs(11),
                      ),
                    ),
                  ),
                  Container(
                    padding: context.symmetricInsets(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(context.rs(999)),
                    ),
                    child: Text(
                      trip.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: context.rs(10),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
