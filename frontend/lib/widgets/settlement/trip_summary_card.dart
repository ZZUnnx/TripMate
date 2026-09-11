import 'package:flutter/material.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';

class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({required this.onReceiveTap, super.key});

  final VoidCallback onReceiveTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.insetsFromLTRB(16, 16, 16, 10),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '제주도 여행',
                style: TextStyle(
                  color: const Color(0xFF060914),
                  fontSize: context.rs(20),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const ResponsiveGap(width: 4),
              const ResponsiveIcon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF5F6680),
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: context.symmetricInsets(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFECE8FF),
                  borderRadius: BorderRadius.circular(context.rs(18)),
                ),
                child: Text(
                  '진행 중',
                  style: TextStyle(
                    color: const Color(0xFF635BFF),
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 10),
          Text(
            '2025. 9. 12 (금) - 9. 15 (월)',
            style: TextStyle(
              color: const Color(0xFF76809A),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w700,
            ),
          ),
          const ResponsiveGap(height: 16),
          Row(
            children: [
              const Expanded(
                child: _SummaryMetric(label: '총 지출', value: '₩648,000'),
              ),
              Container(
                width: context.rs(1),
                height: context.rs(42),
                color: const Color(0xFFEDEFF5),
              ),
              const Expanded(
                child: _SummaryMetric(label: '참여자', value: '4명'),
              ),
              const ResponsiveGap(width: 8),
              Expanded(
                flex: 2,
                child: _ReceiveSummaryButton(onTap: onReceiveTap),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF76809A),
            fontSize: context.rs(12),
            fontWeight: FontWeight.w800,
          ),
        ),
        const ResponsiveGap(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF060914),
            fontSize: context.rs(18),
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _ReceiveSummaryButton extends StatelessWidget {
  const _ReceiveSummaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: Ink(
          height: context.rs(64),
          decoration: BoxDecoration(
            color: const Color(0xFFF0ECFF),
            borderRadius: BorderRadius.circular(context.rs(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '내가 받을 돈',
                style: TextStyle(
                  color: const Color(0xFF635BFF),
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const ResponsiveGap(height: 7),
              Text(
                '+ ₩138,000',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF635BFF),
                  fontSize: context.rs(18),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
