import 'package:flutter/material.dart';

import '../common/responsive.dart';

class CalendarMutedText extends StatelessWidget {
  const CalendarMutedText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: const Color(0xFF60706D),
        fontSize: context.rs(10),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
