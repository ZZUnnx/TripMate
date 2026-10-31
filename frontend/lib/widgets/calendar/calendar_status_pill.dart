import 'package:flutter/material.dart';

import '../common/responsive.dart';

class CalendarStatusPill extends StatelessWidget {
  const CalendarStatusPill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(context.rs(999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: context.rs(10),
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
