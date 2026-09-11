import 'package:flutter/material.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';

class ChatRoomCard extends StatelessWidget {
  const ChatRoomCard({
    required this.title,
    required this.message,
    required this.time,
    required this.avatar,
    this.badgeText,
    this.unreadCount,
    this.isPinned = false,
    super.key,
  });

  final String title;
  final String message;
  final String time;
  final Widget avatar;
  final String? badgeText;
  final int? unreadCount;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: context.rs(80)),
      padding: context.symmetricInsets(horizontal: 14, vertical: 12),
      decoration: cardDecoration(context),
      child: Row(
        children: [
          avatar,
          const ResponsiveGap(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF060914),
                          fontSize: context.rs(16),
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ),
                    if (badgeText != null) ...[
                      const ResponsiveGap(width: 8),
                      _AiBadge(text: badgeText!),
                    ],
                  ],
                ),
                const ResponsiveGap(height: 8),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF76809A),
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 8),
          _ChatTrailing(
            time: time,
            unreadCount: unreadCount,
            isPinned: isPinned,
          ),
        ],
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFECE8FF),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ResponsiveIcon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF635BFF),
            size: 16,
          ),
          const ResponsiveGap(width: 4),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xFF635BFF),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTrailing extends StatelessWidget {
  const _ChatTrailing({
    required this.time,
    this.unreadCount,
    this.isPinned = false,
  });

  final String time;
  final int? unreadCount;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.rs(46),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF76809A),
              fontSize: context.rs(13),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (unreadCount != null) ...[
            const ResponsiveGap(height: 10),
            Container(
              width: context.rs(30),
              height: context.rs(30),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF635BFF),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
          if (isPinned) ...[
            const ResponsiveGap(height: 10),
            Transform.rotate(
              angle: 0.65,
              child: Icon(
                Icons.push_pin_rounded,
                color: const Color(0xFF635BFF),
                size: context.rs(22),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
