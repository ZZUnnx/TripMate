import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Keeps every web route and its overlays inside the same app-sized viewport.
class AppViewport extends StatelessWidget {
  const AppViewport({required this.child, super.key});

  static const double maxWidth = 480;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  size: Size(constraints.maxWidth, mediaQuery.size.height),
                ),
                child: ClipRect(child: child),
              );
            },
          ),
        ),
      ),
    );
  }
}
