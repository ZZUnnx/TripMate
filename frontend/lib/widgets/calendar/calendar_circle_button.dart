import 'package:flutter/material.dart';

import '../common/responsive.dart';

class CalendarCircleButton extends StatelessWidget {
  const CalendarCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 34,
    this.iconSize = 18,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(999)),
        child: SizedBox(
          width: context.rs(size),
          height: context.rs(size),
          child: Icon(
            icon,
            color: const Color(0xFF152523),
            size: context.rs(iconSize),
          ),
        ),
      ),
    );
  }
}
