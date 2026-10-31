import 'package:flutter/material.dart';

import '../common/responsive.dart';

class SettlementCard extends StatelessWidget {
  const SettlementCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: child,
    );
  }
}

class SettlementCardHeader extends StatelessWidget {
  const SettlementCardHeader({
    super.key,
    required this.title,
    required this.action,
  });

  final String title;
  final String action;

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
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          action,
          style: TextStyle(
            color: const Color(0xFF148776),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class SettlementPill extends StatelessWidget {
  const SettlementPill({
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
      padding: context.symmetricInsets(horizontal: 7, vertical: 3),
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

class SettlementAvatar extends StatelessWidget {
  const SettlementAvatar({
    super.key,
    required this.initial,
    required this.color,
    required this.size,
    required this.fontSize,
  });

  final String initial;
  final Color color;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(size),
      height: context.rs(size),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: context.rs(2)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: const Color(0xFF152523),
          fontSize: context.rs(fontSize),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
