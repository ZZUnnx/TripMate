import 'package:flutter/material.dart';

import '../common/responsive.dart';

class ChatListLoadingState extends StatelessWidget {
  const ChatListLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.symmetricInsets(vertical: 52),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF0B5F55)),
      ),
    );
  }
}

class ChatListStateCard extends StatelessWidget {
  const ChatListStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0B5F55), size: context.rs(36)),
          const ResponsiveGap(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(18),
              fontWeight: FontWeight.w700,
            ),
          ),
          const ResponsiveGap(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(14),
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const ResponsiveGap(height: 18),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B5F55),
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
