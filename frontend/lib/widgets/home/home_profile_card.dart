import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../common/responsive.dart';

class HomeProfileCard extends StatelessWidget {
  const HomeProfileCard({super.key, this.tripCount, this.companionCount});

  final int? tripCount;
  final int? companionCount;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.nickname?.trim().isNotEmpty == true
        ? auth.nickname!.trim()
        : '여행자';
    final initial = name.characters.first;

    return Container(
      padding: context.insetsFromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDCE6E3))),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(48),
            height: context.rs(48),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF148776),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rs(18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        auth.isLoggedIn ? name : '로그인하세요',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF152523),
                          fontSize: context.rs(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const ResponsiveGap(width: 6),
                    Container(
                      padding: context.symmetricInsets(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF3EE),
                        borderRadius: BorderRadius.circular(context.rs(999)),
                      ),
                      child: Text(
                        '여행 메이트',
                        style: TextStyle(
                          color: const Color(0xFF0B5F55),
                          fontSize: context.rs(9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 3),
                Text(
                  auth.isLoggedIn
                      ? '참여 여행 ${tripCount ?? '—'}개 · 동행 ${companionCount ?? '—'}명'
                      : '로그인하고 여행을 시작해보세요',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: const Color(0xFFF0F5F4),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: auth.isLoggedIn
                  ? () => context.read<AuthProvider>().logout()
                  : () => Navigator.pushNamed(context, '/login'),
              child: SizedBox(
                width: context.rs(32),
                height: context.rs(32),
                child: Icon(
                  auth.isLoggedIn ? Icons.settings_outlined : Icons.login,
                  color: const Color(0xFF60706D),
                  size: context.rs(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
