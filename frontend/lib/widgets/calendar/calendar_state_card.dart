import 'package:flutter/material.dart';

import '../common/responsive.dart';

class CalendarStateCard extends StatelessWidget {
  const CalendarStateCard({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const ResponsiveGap(height: 10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
