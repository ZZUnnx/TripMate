import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'presentation/settlement_sample_data.dart';
import 'settlement_card_components.dart';

class SettlementPlacesCard extends StatelessWidget {
  const SettlementPlacesCard({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rows = compact ? sampleOverviewPlaceSpends : samplePlaceSpends;

    return SettlementCard(
      child: Column(
        children: [
          SettlementCardHeader(
            title: '장소별 지출',
            action: compact ? '상세 보기' : '5개 장소',
          ),
          const ResponsiveGap(height: 10),
          ...List.generate(rows.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: context.rs(index == rows.length - 1 ? 0 : 9),
              ),
              child: _PlaceSpendRow(data: rows[index]),
            );
          }),
        ],
      ),
    );
  }
}

class _PlaceSpendRow extends StatelessWidget {
  const _PlaceSpendRow({required this.data});

  final SettlementPlaceSpendData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.rs(54),
          child: Text(
            data.label,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const ResponsiveGap(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: context.rs(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3F2),
                  borderRadius: BorderRadius.circular(context.rs(999)),
                ),
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * data.ratio,
                  height: context.rs(7),
                  decoration: BoxDecoration(
                    color: data.color,
                    borderRadius: BorderRadius.circular(context.rs(999)),
                  ),
                ),
              );
            },
          ),
        ),
        const ResponsiveGap(width: 8),
        SizedBox(
          width: context.rs(58),
          child: Text(
            data.amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(10),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
