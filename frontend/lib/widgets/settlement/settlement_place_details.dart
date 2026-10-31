import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'presentation/settlement_sample_data.dart';
import 'settlement_card_components.dart';

class SettlementPlaceDetails extends StatelessWidget {
  const SettlementPlaceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SettlementCard(
      child: Column(
        children: [
          const SettlementCardHeader(title: '장소별 결제 내역', action: '23건'),
          const ResponsiveGap(height: 10),
          ...List.generate(samplePlaceDetails.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: context.rs(
                  index == samplePlaceDetails.length - 1 ? 0 : 10,
                ),
              ),
              child: _PlaceDetailItem(data: samplePlaceDetails[index]),
            );
          }),
        ],
      ),
    );
  }
}

class _PlaceDetailItem extends StatelessWidget {
  const _PlaceDetailItem({required this.data});

  final SettlementPlaceDetailData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SettlementPill(
                label: data.place,
                foreground: data.color,
                background: data.background,
              ),
              const ResponsiveGap(width: 8),
              Expanded(
                child: Text(
                  data.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                data.amount,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 8),
          Column(
            children: data.payments
                .map(
                  (payment) => Padding(
                    padding: EdgeInsets.only(bottom: context.rs(6)),
                    child: _PaymentRow(payment: payment),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final SettlementPaymentData payment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SettlementAvatar(
          initial: payment.initial,
          color: payment.avatarColor,
          size: 24,
          fontSize: 9,
        ),
        const ResponsiveGap(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.name,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const ResponsiveGap(height: 2),
              Text(
                payment.detail,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
