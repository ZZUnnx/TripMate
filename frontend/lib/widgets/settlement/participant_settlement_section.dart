import 'package:flutter/material.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';
import 'section_title.dart';

class ParticipantSettlementSection extends StatelessWidget {
  const ParticipantSettlementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SettlementSectionTitle(title: '참여자별 정산 현황', actionLabel: '더보기'),
        ResponsiveGap(height: 12),
        _ParticipantCard(
          name: '나 (준영) ♕',
          paid: '₩300,000',
          share: '₩162,000',
          balance: '+ ₩138,000',
          avatarColor: Color(0xFFECE8FF),
          iconColor: Color(0xFF635BFF),
          isPositive: true,
        ),
        ResponsiveGap(height: 8),
        _ParticipantCard(
          name: '민수',
          paid: '₩100,000',
          share: '₩162,000',
          balance: '- ₩62,000',
          avatarColor: Color(0xFFFFE4EC),
          iconColor: Color(0xFFF05A7A),
        ),
        ResponsiveGap(height: 8),
        _ParticipantCard(
          name: '서연',
          paid: '₩120,000',
          share: '₩162,000',
          balance: '- ₩42,000',
          avatarColor: Color(0xFFE4EEFF),
          iconColor: Color(0xFF5D8BFF),
        ),
        ResponsiveGap(height: 8),
        _ParticipantCard(
          name: '현우',
          paid: '₩128,000',
          share: '₩162,000',
          balance: '- ₩34,000',
          avatarColor: Color(0xFFE1F5EA),
          iconColor: Color(0xFF45B878),
        ),
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.name,
    required this.paid,
    required this.share,
    required this.balance,
    required this.avatarColor,
    required this.iconColor,
    this.isPositive = false,
  });

  final String name;
  final String paid;
  final String share;
  final String balance;
  final Color avatarColor;
  final Color iconColor;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 12, vertical: 10),
      decoration: cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: context.rs(36),
            height: context.rs(36),
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: iconColor,
              size: context.rs(22),
            ),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF121827),
                fontSize: context.rs(14),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const ResponsiveGap(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniAmountRow(label: '결제', amount: paid),
              const ResponsiveGap(height: 4),
              _MiniAmountRow(label: '부담', amount: share),
            ],
          ),
          const ResponsiveGap(width: 14),
          SizedBox(
            width: context.rs(82),
            child: Text(
              balance,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isPositive
                    ? const Color(0xFF635BFF)
                    : const Color(0xFFF05A7A),
                fontSize: context.rs(15),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAmountRow extends StatelessWidget {
  const _MiniAmountRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.rs(34),
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF76809A),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: const Color(0xFF121827),
            fontSize: context.rs(12),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
