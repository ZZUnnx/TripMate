import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/common/responsive.dart';
import '../../widgets/home/bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    this.currentIndex = 0,
    this.onNavigationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onNavigationSelected;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF9),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : kDesignWidth;
              final scale = contentWidth / kDesignWidth;

              return ResponsiveScope(
                scale: scale,
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Stack(
                      children: [
                        ListView(
                          padding: context.insetsFromLTRB(0, 0, 0, 86),
                          children: const [
                            _HomeTopHeader(),
                            _ProfileCard(),
                            _ActiveTripSection(),
                            _NeedsAttentionSection(),
                            _QuickStatsSection(),
                            _UpcomingTripsSection(),
                            _MonthlyScheduleSection(),
                          ],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BottomNavigation(
                            currentIndex: currentIndex,
                            onItemSelected: onNavigationSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeTopHeader extends StatelessWidget {
  const _HomeTopHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Padding(
        padding: context.symmetricInsets(horizontal: 18),
        child: Row(
          children: [
            Container(
              width: context.rs(30),
              height: context.rs(30),
              decoration: BoxDecoration(
                color: const Color(0xFF148776),
                borderRadius: BorderRadius.circular(context.rs(10)),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: context.rs(16),
              ),
            ),
            const ResponsiveGap(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '트립메이트',
                    style: TextStyle(
                      color: const Color(0xFF152523),
                      fontSize: context.rs(18),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const ResponsiveGap(height: 2),
                  Text(
                    '우리의 여행이 한곳에',
                    style: TextStyle(
                      color: const Color(0xFF60706D),
                      fontSize: context.rs(11),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderCircleButton(icon: Icons.search_rounded, onTap: () {}),
            const ResponsiveGap(width: 8),
            _HeaderCircleButton(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: context.rs(34),
          height: context.rs(34),
          child: Icon(
            icon,
            color: const Color(0xFF152523),
            size: context.rs(18),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.nickname?.trim().isNotEmpty == true
        ? auth.nickname!.trim()
        : '김민지';
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
                        '여행 마스터',
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
                  auth.isLoggedIn ? '총 12번의 여행 · 4명과 함께' : '로그인하고 여행을 시작해보세요',
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insetsFromLTRB(18, 14, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(13),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            action,
            style: TextStyle(
              color: const Color(0xFF148776),
              fontSize: context.rs(11),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripSection extends StatelessWidget {
  const _ActiveTripSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionHeader(title: '다가오는 여행', action: '전체 보기'),
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

class _NeedsAttentionSection extends StatelessWidget {
  const _NeedsAttentionSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SectionHeader(title: '확인 필요', action: '3건'),
        _AttentionItem(
          icon: Icons.route_outlined,
          title: '일정 검토 요청',
          meta: '오늘',
          description: '봄바람 따라, 제주 · 2건의 일정 시간이 변경됨',
        ),
        _AttentionItem(
          icon: Icons.account_balance_wallet_outlined,
          title: '미완료 정산 요청',
          meta: '2건',
          description: '오사카 겨울 여행 · 정산 요청이 2일째 미완료',
        ),
        _AttentionItem(
          icon: Icons.calendar_month_outlined,
          title: '예약 마감 또는 변경',
          meta: '1건',
          description: '강릉 당일치기 · 예약 변경 알림이 도착했어요',
        ),
      ],
    );
  }
}

class _AttentionItem extends StatelessWidget {
  const _AttentionItem({
    required this.icon,
    required this.title,
    required this.meta,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String meta;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.insetsFromLTRB(18, 10, 18, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F5F4))),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(36),
            height: context.rs(36),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F4),
              borderRadius: BorderRadius.circular(context.rs(10)),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF27864),
              size: context.rs(17),
            ),
          ),
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      meta,
                      style: TextStyle(
                        color: const Color(0xFFF27864),
                        fontSize: context.rs(11),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 3),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  const _QuickStatsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insetsFromLTRB(18, 14, 18, 0),
      child: Row(
        children: const [
          Expanded(
            child: _QuickStatCard(
              icon: Icons.route_outlined,
              label: '다음 일정',
              value: '4/18 08:20',
              detail: '김포공항 집결 · 봄바람 따라 제주',
            ),
          ),
          ResponsiveGap(width: 10),
          Expanded(
            child: _QuickStatCard(
              icon: Icons.account_balance_wallet_outlined,
              label: '전체 정산',
              value: '₩842,600',
              detail: '7건 자동 분류 완료',
              detailColor: Color(0xFF2F9D69),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.detailColor = const Color(0xFF8A9895),
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color detailColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.symmetricInsets(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.rs(24),
                height: context.rs(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EC),
                  borderRadius: BorderRadius.circular(context.rs(6)),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFF27864),
                  size: context.rs(13),
                ),
              ),
              const ResponsiveGap(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(11),
                ),
              ),
            ],
          ),
          const ResponsiveGap(height: 8),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF152523),
              fontSize: context.rs(15),
              fontWeight: FontWeight.w700,
            ),
          ),
          const ResponsiveGap(height: 8),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: detailColor, fontSize: context.rs(10)),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTripsSection extends StatelessWidget {
  const _UpcomingTripsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SectionHeader(title: '예정된 여행', action: '+ 새 여행'),
        _TripListItem(
          emoji: '🏯',
          emojiBackground: Color(0xFF4E79C7),
          title: '오사카 겨울 여행',
          status: '계획 중',
          trailing: 'D-78',
          description: '12월 예정 · 4명과 함께',
          statusColor: Color(0xFF4E79C7),
          statusBackground: Color(0xFFEAF0FB),
        ),
        _TripListItem(
          emoji: '🌊',
          emojiBackground: Color(0xFFE9E1F5),
          title: '강릉 당일치기',
          status: '완료',
          trailing: '3월 2일',
          description: '✓ 정산 완료',
          muted: true,
        ),
      ],
    );
  }
}

class _TripListItem extends StatelessWidget {
  const _TripListItem({
    required this.emoji,
    required this.emojiBackground,
    required this.title,
    required this.status,
    required this.trailing,
    required this.description,
    this.statusColor = const Color(0xFF8A9895),
    this.statusBackground = const Color(0xFFF0F5F4),
    this.muted = false,
  });

  final String emoji;
  final Color emojiBackground;
  final String title;
  final String status;
  final String trailing;
  final String description;
  final Color statusColor;
  final Color statusBackground;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.insetsFromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF7FAF9) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFF0F5F4))),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(46),
            height: context.rs(46),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: emojiBackground,
              borderRadius: BorderRadius.circular(context.rs(14)),
            ),
            child: Text(emoji, style: TextStyle(fontSize: context.rs(20))),
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
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: muted
                              ? const Color(0xFF8A9895)
                              : const Color(0xFF152523),
                          fontSize: context.rs(14),
                          fontWeight: muted ? FontWeight.w600 : FontWeight.w700,
                        ),
                      ),
                    ),
                    const ResponsiveGap(width: 6),
                    Container(
                      padding: context.symmetricInsets(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(context.rs(999)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: context.rs(9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      trailing,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: context.rs(11),
                        fontWeight: muted ? FontWeight.w400 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: muted
                        ? const Color(0xFF2F9D69)
                        : const Color(0xFF60706D),
                    fontSize: context.rs(11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyScheduleSection extends StatelessWidget {
  const _MonthlyScheduleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SectionHeader(title: '이번 달 일정', action: '캘린더 보기'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              _ScheduleListItem(
                month: '4월',
                day: '18',
                title: '김포공항 집결',
                detail: '봄바람 따라, 제주 · 08:20',
                tag: '제주',
              ),
              ResponsiveGap(height: 8),
              _ScheduleListItem(
                month: '4월',
                day: '19',
                title: '우도 해변 투어',
                detail: '봄바람 따라, 제주 · 10:00',
                tag: '제주',
              ),
              ResponsiveGap(height: 8),
              _ScheduleListItem(
                month: '12월',
                day: '24',
                title: '오사카 출발',
                detail: '오사카 겨울 여행 · 미정',
                tag: '오사카',
                blue: true,
              ),
              ResponsiveGap(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleListItem extends StatelessWidget {
  const _ScheduleListItem({
    required this.month,
    required this.day,
    required this.title,
    required this.detail,
    required this.tag,
    this.blue = false,
  });

  final String month;
  final String day;
  final String title;
  final String detail;
  final String tag;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    final color = blue ? const Color(0xFF4E79C7) : const Color(0xFF0B5F55);
    final background = blue ? const Color(0xFFEAF0FB) : const Color(0xFFDDF3EE);

    return Container(
      padding: context.symmetricInsets(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Row(
        children: [
          Container(
            width: context.rs(36),
            height: context.rs(36),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.rs(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: TextStyle(color: color, fontSize: context.rs(9)),
                ),
                Text(
                  day,
                  style: TextStyle(
                    color: color,
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(10),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: context.symmetricInsets(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.rs(999)),
            ),
            child: Text(
              tag,
              style: TextStyle(color: color, fontSize: context.rs(9)),
            ),
          ),
        ],
      ),
    );
  }
}
