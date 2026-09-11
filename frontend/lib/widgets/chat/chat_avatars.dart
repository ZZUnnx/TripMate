import 'package:flutter/material.dart';

import '../common/responsive.dart';

enum TravelAvatarStyle { jeju, hokkaido, busan, danang }

class TravelAvatar extends StatelessWidget {
  const TravelAvatar({required this.style, super.key});

  final TravelAvatarStyle style;

  @override
  Widget build(BuildContext context) {
    final palette = switch (style) {
      TravelAvatarStyle.jeju => const [
        Color(0xFF9FCCFF),
        Color(0xFF6AB4CA),
        Color(0xFF315C43),
      ],
      TravelAvatarStyle.hokkaido => const [
        Color(0xFF9BC2FF),
        Color(0xFFE8F2FF),
        Color(0xFF5F79AA),
      ],
      TravelAvatarStyle.busan => const [
        Color(0xFF7EC7FF),
        Color(0xFF34A7BF),
        Color(0xFFECEFF4),
      ],
      TravelAvatarStyle.danang => const [
        Color(0xFF80C7FF),
        Color(0xFF54C9D6),
        Color(0xFF69A453),
      ],
    };

    return ClipOval(
      child: SizedBox(
        width: context.rs(58),
        height: context.rs(58),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette[0], palette[1]],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: context.rs(6),
                right: context.rs(6),
                bottom: context.rs(12),
                child: Container(
                  height: context.rs(16),
                  decoration: BoxDecoration(
                    color: palette[2],
                    borderRadius: BorderRadius.circular(context.rs(24)),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: context.rs(4),
                child: Container(
                  height: context.rs(12),
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              if (style == TravelAvatarStyle.danang)
                Positioned(
                  right: context.rs(10),
                  top: context.rs(16),
                  child: Icon(
                    Icons.park_rounded,
                    color: const Color(0xFF3F8D55),
                    size: context.rs(24),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.rs(58),
      height: context.rs(58),
      child: Wrap(
        spacing: context.rs(2),
        runSpacing: context.rs(2),
        children: const [
          _MiniPersonAvatar(hair: Color(0xFF2E3440), face: Color(0xFFF1C6A6)),
          _MiniPersonAvatar(hair: Color(0xFF222936), face: Color(0xFFE8B998)),
          _MiniPersonAvatar(hair: Color(0xFF5E4739), face: Color(0xFFFFD8BA)),
          _MiniPersonAvatar(hair: Color(0xFF7B5B4B), face: Color(0xFFFFDCC4)),
        ],
      ),
    );
  }
}

class FamilyAvatar extends StatelessWidget {
  const FamilyAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.rs(58),
      height: context.rs(58),
      child: const Stack(
        children: [
          _LargePersonAvatar(
            hair: Color(0xFF6A4B3D),
            face: Color(0xFFFFD9BD),
            alignLeft: true,
          ),
          _LargePersonAvatar(
            hair: Color(0xFFC9C1B6),
            face: Color(0xFFE7BFA4),
            alignLeft: false,
          ),
        ],
      ),
    );
  }
}

class CoupleAvatar extends StatelessWidget {
  const CoupleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.rs(58),
      height: context.rs(58),
      child: const Stack(
        children: [
          _LargePersonAvatar(
            hair: Color(0xFF252B34),
            face: Color(0xFFF2C6A8),
            alignLeft: true,
          ),
          _LargePersonAvatar(
            hair: Color(0xFF1E2530),
            face: Color(0xFFE6B18F),
            alignLeft: false,
          ),
        ],
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(58),
      height: context.rs(58),
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EC),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: context.rs(8),
            child: Container(
              width: context.rs(34),
              height: context.rs(32),
              decoration: const BoxDecoration(
                color: Color(0xFF815E4E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: context.rs(18),
            child: Container(
              width: context.rs(24),
              height: context.rs(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD8BA),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: context.rs(4),
            child: Container(
              width: context.rs(38),
              height: context.rs(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.rs(18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPersonAvatar extends StatelessWidget {
  const _MiniPersonAvatar({required this.hair, required this.face});

  final Color hair;
  final Color face;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(27),
      height: context.rs(27),
      decoration: const BoxDecoration(
        color: Color(0xFFE8ECF4),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: context.rs(5),
            child: Container(
              width: context.rs(17),
              height: context.rs(15),
              decoration: BoxDecoration(color: hair, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            top: context.rs(9),
            child: Container(
              width: context.rs(12),
              height: context.rs(12),
              decoration: BoxDecoration(color: face, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

class _LargePersonAvatar extends StatelessWidget {
  const _LargePersonAvatar({
    required this.hair,
    required this.face,
    required this.alignLeft,
  });

  final Color hair;
  final Color face;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: alignLeft ? 0 : context.rs(24),
      child: Container(
        width: context.rs(38),
        height: context.rs(58),
        decoration: const BoxDecoration(
          color: Color(0xFFE8ECF4),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: context.rs(8),
              child: Container(
                width: context.rs(24),
                height: context.rs(24),
                decoration: BoxDecoration(color: hair, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              top: context.rs(16),
              child: Container(
                width: context.rs(17),
                height: context.rs(18),
                decoration: BoxDecoration(color: face, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
