import 'package:flutter/material.dart';

import '../../common/responsive.dart';

class ChatMessageComposer extends StatelessWidget {
  const ChatMessageComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isExpanded,
    required this.onAddTap,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isExpanded;
  final VoidCallback onAddTap;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(70),
      padding: context.insetsFromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDCE6E3))),
      ),
      child: Row(
        children: [
          _RoundComposerButton(
            icon: isExpanded ? Icons.close_rounded : Icons.add_rounded,
            isActive: isExpanded,
            onTap: onAddTap,
          ),
          const ResponsiveGap(width: 8),
          Expanded(
            child: Container(
              height: context.rs(38),
              padding: context.symmetricInsets(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF9),
                border: Border.all(color: const Color(0xFFDCE6E3)),
                borderRadius: BorderRadius.circular(context.rs(999)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: isExpanded
                            ? '사진, 일정, 정산을 함께 보내보세요'
                            : '메시지를 입력하세요',
                        hintStyle: TextStyle(color: Color(0xFF8A9895)),
                      ),
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: context.rs(24),
                      height: context.rs(24),
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: Color(0xFF8A9895),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const ResponsiveGap(width: 8),
          _SendButton(isSending: isSending, onTap: onSend),
        ],
      ),
    );
  }
}

class _RoundComposerButton extends StatelessWidget {
  const _RoundComposerButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFF148776) : const Color(0xFFEEF3F2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: context.rs(34),
          height: context.rs(34),
          child: Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFF60706D),
            size: context.rs(18),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isSending, required this.onTap});

  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isSending ? null : onTap,
        child: SizedBox(
          width: context.rs(34),
          height: context.rs(34),
          child: isSending
              ? const Padding(
                  padding: EdgeInsets.all(9),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: context.rs(17),
                ),
        ),
      ),
    );
  }
}
