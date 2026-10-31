import 'package:flutter/material.dart';

import '../../common/responsive.dart';

class ChatMessageState extends StatelessWidget {
  const ChatMessageState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.symmetricInsets(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF148776), size: context.rs(42)),
            const ResponsiveGap(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF152523),
                fontSize: context.rs(18),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...[
              const ResponsiveGap(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const ResponsiveGap(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
