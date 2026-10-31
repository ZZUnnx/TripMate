import 'package:flutter/material.dart';

import '../common/responsive.dart';

class ChatListSectionHeader extends StatelessWidget {
  const ChatListSectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF152523),
            fontSize: context.rs(14),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$count개',
          style: TextStyle(
            color: const Color(0xFF0B5F55),
            fontSize: context.rs(11),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
