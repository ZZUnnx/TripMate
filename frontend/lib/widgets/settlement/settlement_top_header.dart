import 'package:flutter/material.dart';

import '../common/responsive.dart';

class SettlementTopHeader extends StatelessWidget {
  const SettlementTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Row(
        children: [
          Container(
            width: context.rs(30),
            height: context.rs(30),
            decoration: BoxDecoration(
              color: const Color(0xFF148776),
              borderRadius: BorderRadius.circular(context.rs(10)),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: context.rs(16),
            ),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '여행 정산',
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(18),
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 2),
                Text(
                  '제주 봄 여행 · 여행 종료',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: SizedBox(
                width: context.rs(34),
                height: context.rs(34),
                child: Icon(
                  Icons.download_rounded,
                  color: const Color(0xFF152523),
                  size: context.rs(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
