import 'package:flutter/material.dart';

import '../common/responsive.dart';

enum ChatRoomBadgeStyle { mint, neutral, coral }

class ChatRoomRow extends StatelessWidget {
  const ChatRoomRow({
    super.key,
    required this.title,
    required this.message,
    required this.date,
    required this.time,
    required this.badgeText,
    required this.avatarLabel,
    required this.avatarColor,
    required this.badgeStyle,
    required this.onTap,
  });

  final String title;
  final String message;
  final String date;
  final String time;
  final String badgeText;
  final String avatarLabel;
  final Color avatarColor;
  final ChatRoomBadgeStyle badgeStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: Ink(
          padding: context.symmetricInsets(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDCE6E3)),
            borderRadius: BorderRadius.circular(context.rs(12)),
          ),
          child: Row(
            children: [
              _ChatAvatar(label: avatarLabel, color: avatarColor),
              const ResponsiveGap(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF152523),
                              fontSize: context.rs(15),
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const ResponsiveGap(width: 8),
                        Text(
                          date,
                          maxLines: 1,
                          style: TextStyle(
                            color: const Color(0xFF8A9895),
                            fontSize: context.rs(10),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const ResponsiveGap(height: 6),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF60706D),
                        fontSize: context.rs(13),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const ResponsiveGap(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ChatBadge(text: badgeText, style: badgeStyle),
                        Text(
                          time,
                          style: TextStyle(
                            color: const Color(0xFF8A9895),
                            fontSize: context.rs(10),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(40),
      height: context.rs(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: context.rs(2)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFF152523),
          fontSize: context.rs(label.length > 1 ? 11 : 12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChatBadge extends StatelessWidget {
  const _ChatBadge({required this.text, required this.style});

  final String text;
  final ChatRoomBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = switch (style) {
      ChatRoomBadgeStyle.mint => (
        background: const Color(0xFFDDF3EE),
        foreground: const Color(0xFF0B5F55),
      ),
      ChatRoomBadgeStyle.neutral => (
        background: const Color(0xFFEEF3F2),
        foreground: const Color(0xFF60706D),
      ),
      ChatRoomBadgeStyle.coral => (
        background: const Color(0xFFFFF0EC),
        foreground: const Color(0xFFF27864),
      ),
    };

    return Container(
      padding: context.symmetricInsets(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(context.rs(999)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.foreground,
          fontSize: context.rs(10),
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
