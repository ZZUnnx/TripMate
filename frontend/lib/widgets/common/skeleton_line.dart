import 'package:flutter/material.dart';

import 'responsive.dart';

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    required this.width,
    required this.height,
    this.color = const Color(0xFFE0E4EF),
    super.key,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(width),
      height: context.rs(height),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.rs(height)),
      ),
    );
  }
}
