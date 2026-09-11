import 'package:flutter/material.dart';

import '../common/responsive.dart';

class SettlementHeader extends StatelessWidget {
  const SettlementHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정산',
                style: TextStyle(
                  color: const Color(0xFF121827),
                  fontSize: context.rs(35),
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const ResponsiveGap(height: 6),
              Text(
                '함께한 여행의 지출을 정리해요!',
                style: TextStyle(
                  color: const Color(0xFF7C83A0),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: Ink(
              width: context.rs(50),
              height: context.rs(50),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7468FF), Color(0xFF9F77F2)],
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: context.rs(32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
