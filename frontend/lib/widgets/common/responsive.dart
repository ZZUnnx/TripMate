import 'package:flutter/material.dart';

const double kDesignWidth = 430.0;

class ResponsiveScope extends InheritedWidget {
  const ResponsiveScope({required this.scale, required super.child, super.key});

  final double scale;

  static double scaleOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ResponsiveScope>()
            ?.scale ??
        1;
  }

  @override
  bool updateShouldNotify(ResponsiveScope oldWidget) {
    return scale != oldWidget.scale;
  }
}

extension ResponsiveSizing on BuildContext {
  double rs(double value) => value * ResponsiveScope.scaleOf(this);

  EdgeInsets insetsFromLTRB(
    double left,
    double top,
    double right,
    double bottom,
  ) {
    return EdgeInsets.fromLTRB(rs(left), rs(top), rs(right), rs(bottom));
  }

  EdgeInsets symmetricInsets({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: rs(horizontal),
      vertical: rs(vertical),
    );
  }
}

class ResponsiveGap extends StatelessWidget {
  const ResponsiveGap({this.width, this.height, super.key});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == null ? null : context.rs(width!),
      height: height == null ? null : context.rs(height!),
    );
  }
}

class ResponsiveIcon extends StatelessWidget {
  const ResponsiveIcon(
    this.icon, {
    required this.color,
    required this.size,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: context.rs(size));
  }
}
