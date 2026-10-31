import 'package:flutter/material.dart';

import '../calendar_muted_text.dart';

import '../../../models/trip_member.dart';
import '../calendar_status_pill.dart';
import '../../common/responsive.dart';

class TripOverviewCard extends StatelessWidget {
  const TripOverviewCard({
    super.key,
    required this.dateRange,
    required this.scheduleCount,
    required this.destination,
    required this.membersFuture,
  });

  final String dateRange;
  final int scheduleCount;
  final String destination;
  final Future<List<TripMember>>? membersFuture;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: context.rs(66)),
      padding: context.symmetricInsets(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE6E3)),
        borderRadius: BorderRadius.circular(context.rs(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateRange,
                  style: TextStyle(
                    color: const Color(0xFF152523),
                    fontSize: context.rs(15),
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const ResponsiveGap(height: 5),
                Row(
                  children: [
                    CalendarStatusPill(
                      label: '확정',
                      foreground: const Color(0xFF0B5F55),
                      background: const Color(0xFFDDF3EE),
                    ),
                    const ResponsiveGap(width: 5),
                    Flexible(
                      child: Text(
                        '$destination · 일정 $scheduleCount개',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF60706D),
                          fontSize: context.rs(10),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 8),
          FutureBuilder<List<TripMember>>(
            future: membersFuture,
            builder: (context, snapshot) {
              final members = snapshot.data ?? const <TripMember>[];
              final label = snapshot.connectionState == ConnectionState.waiting
                  ? '참여자 확인 중'
                  : members.isEmpty
                  ? '참여자 정보 없음'
                  : '${members.length}명 참여';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ParticipantAvatars(members: members),
                  const ResponsiveGap(height: 4),
                  CalendarMutedText(label),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ParticipantAvatars extends StatelessWidget {
  const _ParticipantAvatars({required this.members});

  final List<TripMember> members;

  @override
  Widget build(BuildContext context) {
    final avatars = members.take(4).toList();

    return SizedBox(
      width: context.rs(83),
      height: context.rs(26),
      child: Stack(
        children: [
          if (avatars.isEmpty)
            Positioned(
              right: 0,
              child: Container(
                width: context.rs(26),
                height: context.rs(26),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3EE),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: context.rs(2)),
                ),
                child: Icon(
                  Icons.group_outlined,
                  color: const Color(0xFF0B5F55),
                  size: context.rs(13),
                ),
              ),
            )
          else
            for (var index = 0; index < avatars.length; index++)
              Positioned(
                left: context.rs(index * 19),
                child: Container(
                  width: context.rs(26),
                  height: context.rs(26),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _avatarColor(index),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: context.rs(2),
                    ),
                  ),
                  child: Text(
                    _avatarInitial(avatars[index].nickname),
                    style: TextStyle(
                      color: const Color(0xFF152523),
                      fontSize: context.rs(10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

String _avatarInitial(String nickname) {
  final trimmed = nickname.trim();

  if (trimmed.isEmpty) {
    return '?';
  }

  return trimmed.characters.first;
}

Color _avatarColor(int index) {
  const colors = [
    Color(0xFFDDF3EE),
    Color(0xFFDDEEF9),
    Color(0xFFFFE8D9),
    Color(0xFFE9E1F5),
  ];

  return colors[index % colors.length];
}
