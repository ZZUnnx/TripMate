import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'home_section_header.dart';

class ActiveTripSection extends StatelessWidget {
  const ActiveTripSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HomeSectionHeader(title: '다가오는 여행', action: '전체 보기'),
        SizedBox(
          height: context.rs(140),
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/home_active_trip.png',
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF092621).withValues(alpha: 0.76),
                      const Color(0xFF051714).withValues(alpha: 0.97),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: context.symmetricInsets(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: context.symmetricInsets(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDDF3EE),
                                  borderRadius: BorderRadius.circular(
                                    context.rs(999),
                                  ),
                                ),
                                child: Text(
                                  'D-12 · 진행 중',
                                  style: TextStyle(
                                    color: const Color(0xFF0B5F55),
                                    fontSize: context.rs(10),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const ResponsiveGap(width: 6),
                              Text(
                                'JEJU · 4월 18-21일',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: context.rs(10),
                                ),
                              ),
                            ],
                          ),
                          const ResponsiveGap(height: 5),
                          Text(
                            '봄바람 따라, 제주',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rs(20),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const ResponsiveGap(height: 5),
                          Text(
                            '일정 8개 · 예약 3건 · 함께 4명',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: context.rs(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _MiniAvatarStack(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniAvatarStack extends StatelessWidget {
  const _MiniAvatarStack();

  @override
  Widget build(BuildContext context) {
    const labels = ['민', '서', '준', '나'];
    const colors = [
      Color(0xFFDDEEF9),
      Color(0xFFFFE8D9),
      Color(0xFFE9E1F5),
      Color(0xFFDDF3EE),
    ];

    return SizedBox(
      width: context.rs(80),
      height: context.rs(28),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          for (var i = 0; i < labels.length; i++)
            Positioned(
              right: context.rs((labels.length - 1 - i) * 19),
              child: Container(
                width: context.rs(26),
                height: context.rs(26),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: context.rs(2)),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
