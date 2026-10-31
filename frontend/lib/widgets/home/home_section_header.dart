import 'package:flutter/material.dart';

import '../common/responsive.dart';

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.action,
  });

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insetsFromLTRB(18, 14, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(13),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            action,
            style: TextStyle(
              color: const Color(0xFF148776),
              fontSize: context.rs(11),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
