import 'package:flutter/material.dart';

import '../../../models/chat_room.dart';
import '../../common/responsive.dart';
import 'chat_detail_circle_button.dart';

class ChatDetailHeader extends StatelessWidget {
  const ChatDetailHeader({
    super.key,
    required this.room,
    required this.onBack,
    required this.onAiSummaryTap,
    required this.onMenuTap,
  });

  final ChatRoom room;
  final VoidCallback onBack;
  final VoidCallback onAiSummaryTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Padding(
        padding: context.symmetricInsets(horizontal: 16),
        child: Row(
          children: [
            ChatDetailCircleButton(
              icon: Icons.chevron_left_rounded,
              onTap: onBack,
            ),
            const ResponsiveGap(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF152523),
                      fontSize: context.rs(18),
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  const ResponsiveGap(height: 2),
                  Text(
                    '${room.memberCount}명',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF60706D),
                      fontSize: context.rs(11),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const ResponsiveGap(width: 10),
            _AiSummaryButton(onTap: onAiSummaryTap),
            const ResponsiveGap(width: 10),
            ChatDetailCircleButton(icon: Icons.search_rounded, onTap: () {}),
            const ResponsiveGap(width: 10),
            ChatDetailCircleButton(icon: Icons.menu_rounded, onTap: onMenuTap),
          ],
        ),
      ),
    );
  }
}

class _AiSummaryButton extends StatelessWidget {
  const _AiSummaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      borderRadius: BorderRadius.circular(context.rs(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(999)),
        child: SizedBox(
          height: context.rs(34),
          child: Padding(
            padding: context.symmetricInsets(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: context.rs(14),
                ),
                const ResponsiveGap(width: 6),
                Text(
                  'AI 요약',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
