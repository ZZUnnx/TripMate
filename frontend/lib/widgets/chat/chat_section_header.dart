import 'package:flutter/material.dart';

import '../common/responsive.dart';

class ChatSectionHeader extends StatelessWidget {
  const ChatSectionHeader({
    required this.title,
    this.showCollapseButton = false,
    super.key,
  });

  final String title;
  final bool showCollapseButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF121827),
            fontSize: context.rs(20),
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const Spacer(),
        if (showCollapseButton)
          const ResponsiveIcon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF424969),
            size: 28,
          ),
      ],
    );
  }
}
