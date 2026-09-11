import 'package:flutter/material.dart';

import '../common/responsive.dart';

// 일정 구분선
class ScheduleDivider extends StatelessWidget {
  const ScheduleDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.symmetricInsets(horizontal: 4),
      child: Container(
        height: context.rs(3),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E6EE),
          borderRadius: BorderRadius.circular(context.rs(1)),
        ),
      ),
    );
  }
}
