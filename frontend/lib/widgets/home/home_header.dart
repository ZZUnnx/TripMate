import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/responsive.dart';
import '../../providers/auth_provider.dart';

// 상단 헤더: 프로필 사진, 이름 영역, 설정 버튼
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    this.subtitle = '즐거운 여행을 준비해볼까요?',
    super.key,
  });

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Row(
      children: [
        // 프로필 사진
        Container(
          width: context.rs(54),
          height: context.rs(54),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8E4FF),
                Color(0xFFDCEAFD),
              ],
            ),
          ),
          child: const ResponsiveIcon(
            Icons.person_outline_rounded,
            color: Color(0xFF7C83A0),
            size: 28,
          ),
        ),

        const ResponsiveGap(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (auth.isLoggedIn)
                Text(
                  auth.nickname ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF121827),
                    fontSize: context.rs(35),
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF121827),
                  ),
                  child: Text(
                    '로그인하세요',
                    style: TextStyle(
                      fontSize: context.rs(28),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              const ResponsiveGap(height: 6),

              Text(
                auth.isLoggedIn
                    ? subtitle
                    : '로그인하고 여행을 시작해보세요',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF7C83A0),
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          color: const Color(0xFF121827),
          iconSize: context.rs(32),
          tooltip: '',
        ),
      ],
    );
  }
}