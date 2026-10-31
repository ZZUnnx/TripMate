import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../common/responsive.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.mine) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _clockText(message.sentAt),
                style: TextStyle(
                  color: const Color(0xFF8A9895),
                  fontSize: context.rs(9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const ResponsiveGap(width: 7),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.rs(250)),
            child: Container(
              padding: context.symmetricInsets(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF148776),
                border: Border.all(color: const Color(0xFF148776)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.rs(13)),
                  topRight: Radius.circular(context.rs(4)),
                  bottomLeft: Radius.circular(context.rs(13)),
                  bottomRight: Radius.circular(context.rs(13)),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rs(12),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PersonBubbleAvatar(name: message.senderNickname),
        const ResponsiveGap(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.rs(256)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.senderNickname,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const ResponsiveGap(height: 4),
              Container(
                padding: context.symmetricInsets(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDCE6E3)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(context.rs(4)),
                    topRight: Radius.circular(context.rs(13)),
                    bottomLeft: Radius.circular(context.rs(13)),
                    bottomRight: Radius.circular(context.rs(13)),
                  ),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const ResponsiveGap(width: 8),
        Text(
          _clockText(message.sentAt),
          style: TextStyle(
            color: const Color(0xFF8A9895),
            fontSize: context.rs(9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _clockText(DateTime sentAt) {
    final hour = sentAt.hour.toString().padLeft(2, '0');
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _PersonBubbleAvatar extends StatelessWidget {
  const _PersonBubbleAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1);
    final colors = [
      const Color(0xFFEAF0FB),
      const Color(0xFFFFE8D9),
      const Color(0xFFE8E1F7),
      const Color(0xFFFFF0EC),
    ];
    final color = colors[name.hashCode.abs() % colors.length];

    return CircleAvatar(
      radius: context.rs(14),
      backgroundColor: color,
      child: Text(
        initial,
        style: TextStyle(
          color: const Color(0xFF152523),
          fontSize: context.rs(10),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
