import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../models/chat_room.dart';
import '../../../models/trip_member.dart';
import '../../common/responsive.dart';

class ChatRoomSideMenu extends StatelessWidget {
  const ChatRoomSideMenu({
    super.key,
    required this.room,
    required this.membersFuture,
    required this.onClose,
    required this.onInviteMember,
    required this.onScheduleSummary,
    required this.onSharedSchedule,
    required this.onSettlement,
    required this.onFiles,
  });

  final ChatRoom room;
  final Future<List<TripMember>> membersFuture;
  final VoidCallback onClose;
  final VoidCallback onInviteMember;
  final VoidCallback onScheduleSummary;
  final VoidCallback onSharedSchedule;
  final VoidCallback onSettlement;
  final VoidCallback onFiles;

  @override
  Widget build(BuildContext context) {
    final menuWidth = context.rs(326);

    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: const Color(0xFF102724).withValues(alpha: 0.44),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: menuWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0B2E28).withValues(alpha: 0.16),
                  blurRadius: context.rs(30),
                  offset: Offset(0, context.rs(10)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  left: false,
                  bottom: false,
                  child: SizedBox(
                    height: context.rs(54),
                    child: Padding(
                      padding: context.symmetricInsets(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '채팅방 정보',
                              style: TextStyle(
                                color: const Color(0xFF152523),
                                fontSize: context.rs(13),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _DrawerCloseButton(onTap: onClose),
                        ],
                      ),
                    ),
                  ),
                ),
                _DrawerTripFeature(room: room),
                Expanded(
                  child: SingleChildScrollView(
                    padding: context.insetsFromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DrawerParticipants(
                          membersFuture: membersFuture,
                          onInvite: onInviteMember,
                        ),
                        const ResponsiveGap(height: 13),
                        const _DrawerDivider(),
                        const ResponsiveGap(height: 10),
                        _DrawerMenuItem(
                          icon: Icons.campaign_outlined,
                          label: '공지',
                          trailing: '1',
                          onTap: onScheduleSummary,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.calendar_month_outlined,
                          label: '공유 일정',
                          trailing: '5개',
                          onTap: onSharedSchedule,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.photo_library_outlined,
                          label: '여행 앨범',
                          trailing: '24장',
                          onTap: onFiles,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.insert_drive_file_outlined,
                          label: '파일',
                          trailing: '3개',
                          onTap: onFiles,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.link_rounded,
                          label: '링크',
                          trailing: '7개',
                          onTap: onFiles,
                        ),
                        _DrawerMenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          label: '정산 현황',
                          trailing: '진행 중',
                          onTap: onSettlement,
                        ),
                        const ResponsiveGap(height: 10),
                        const _DrawerDivider(),
                        const ResponsiveGap(height: 10),
                        _DrawerMenuItem(
                          icon: Icons.notifications_none_rounded,
                          label: '알림 설정',
                          trailing: '켜짐',
                          onTap: () {},
                        ),
                        _DrawerMenuItem(
                          icon: Icons.logout_rounded,
                          label: '채팅방 나가기',
                          isDestructive: true,
                          showChevron: true,
                          onTap: () {},
                        ),
                      ],
                    ),
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

class _DrawerCloseButton extends StatelessWidget {
  const _DrawerCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF3F2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: context.rs(32),
          height: context.rs(32),
          child: Icon(
            Icons.close_rounded,
            color: const Color(0xFF152523),
            size: context.rs(17),
          ),
        ),
      ),
    );
  }
}

class _DrawerTripFeature extends StatelessWidget {
  const _DrawerTripFeature({required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(128),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/chat_drawer_trip.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.03),
                  const Color(0xFF082E29).withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
          Positioned(
            left: context.rs(16),
            right: context.rs(16),
            bottom: context.rs(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rs(18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const ResponsiveGap(height: 3),
                Text(
                  _tripDateLabel(room),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tripDateLabel(ChatRoom room) {
    final startDate = room.startDate;
    final endDate = room.endDate;

    if (startDate == null || endDate == null) {
      return '${room.memberCount}명 참여';
    }

    final nights = endDate.difference(startDate).inDays;
    final days = nights + 1;

    return '${startDate.month}월 ${startDate.day}일 — ${endDate.month}월 ${endDate.day}일 · $nights박 $days일';
  }
}

class _DrawerParticipants extends StatelessWidget {
  const _DrawerParticipants({
    required this.membersFuture,
    required this.onInvite,
  });

  final Future<List<TripMember>> membersFuture;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TripMember>>(
      future: membersFuture,
      builder: (context, snapshot) {
        final members = snapshot.data ?? const <TripMember>[];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: context.rs(72),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF148776)),
            ),
          );
        }

        if (snapshot.hasError || members.isEmpty) {
          return Text(
            '참여자 정보를 불러오지 못했습니다.',
            style: TextStyle(
              color: const Color(0xFF60706D),
              fontSize: context.rs(11),
              fontWeight: FontWeight.w500,
            ),
          );
        }

        final visibleMembers = members.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '참여자 ${members.length}명',
              style: TextStyle(
                color: const Color(0xFF60706D),
                fontSize: context.rs(10),
                fontWeight: FontWeight.w700,
              ),
            ),
            const ResponsiveGap(height: 9),
            Row(
              children: [
                for (final member in visibleMembers)
                  Expanded(child: _DrawerParticipant(member: member)),
                Expanded(child: _DrawerInviteButton(onTap: onInvite)),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DrawerInviteButton extends StatelessWidget {
  const _DrawerInviteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: Padding(
          padding: context.symmetricInsets(vertical: 2),
          child: Column(
            children: [
              Container(
                width: context.rs(40),
                height: context.rs(40),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3EE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBFE5DD),
                    width: context.rs(1),
                  ),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: const Color(0xFF0B5F55),
                  size: context.rs(17),
                ),
              ),
              const ResponsiveGap(height: 5),
              Text(
                '친구 초대',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF0B5F55),
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerParticipant extends StatelessWidget {
  const _DrawerParticipant({required this.member});

  final TripMember member;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFDDF3EE),
      const Color(0xFFDDEEF9),
      const Color(0xFFFFE8D9),
      const Color(0xFFE8E1F7),
    ];
    final color = member.owner
        ? const Color(0xFFDDF3EE)
        : colors[member.nickname.hashCode.abs() % colors.length];

    return Column(
      children: [
        SizedBox(
          width: context.rs(40),
          height: context.rs(40),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: context.rs(19),
                backgroundColor: color,
                child: Text(
                  member.nickname.isEmpty ? '?' : member.nickname[0],
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (member.owner)
                Positioned(
                  right: context.rs(-1),
                  bottom: context.rs(-1),
                  child: Container(
                    width: context.rs(12),
                    height: context.rs(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B5F55),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const ResponsiveGap(height: 5),
        Text(
          member.owner ? '나' : member.nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF152523),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFDCE6E3));
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? const Color(0xFFD95757)
        : const Color(0xFF152523);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: context.rs(38),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: context.rs(17)),
              const ResponsiveGap(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    color: const Color(0xFF8A9895),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (showChevron) ...[
                const ResponsiveGap(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF8A9895),
                  size: context.rs(14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
