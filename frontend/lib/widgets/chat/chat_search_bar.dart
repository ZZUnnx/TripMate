import 'package:flutter/material.dart';

import '../common/responsive.dart';

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(42),
      padding: context.symmetricInsets(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: const Color(0xFF8A9895),
            size: context.rs(16),
          ),
          const ResponsiveGap(width: 8),
          Expanded(
            child: Text(
              '여행명, 장소, 메시지 검색',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF8A9895),
                fontSize: context.rs(13),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
