import 'package:flutter/material.dart';

import '../common/responsive.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '채팅',
                style: TextStyle(
                  color: const Color(0xFF121827),
                  fontSize: context.rs(35),
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const ResponsiveGap(height: 6),
              Text(
                '여행 대화와 일정 소통',
                style: TextStyle(
                  color: const Color(0xFF7C83A0),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _HeaderIconButton(icon: Icons.search_rounded, onTap: () {}),
        const ResponsiveGap(width: 14),
        _HeaderIconButton(
          icon: Icons.add_rounded,
          isPrimary: true,
          onTap: () {},
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final size = isPrimary ? context.rs(58) : context.rs(48);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isPrimary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7468FF), Color(0xFF635BFF)],
                  )
                : null,
            color: isPrimary ? null : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : const Color(0xFF060914),
            size: context.rs(isPrimary ? 34 : 32),
          ),
        ),
      ),
    );
  }
}
