import 'package:flutter/material.dart';

import '../../models/home_data.dart';
import '../common/responsive.dart';
import 'home_section_header.dart';

class ActiveTripSection extends StatelessWidget {
  const ActiveTripSection({
    super.key,
    required this.data,
    this.onTap,
    this.onViewAll,
  });
  final HomeData data;
  final VoidCallback? onTap;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final trip = data.activeTrip;
    final schedules = trip == null ? null : data.schedulesFor(trip.id);
    final members = trip == null ? null : data.settlementFor(trip.id)?.members;
    return Column(
      children: [
        HomeSectionHeader(
          title: '가장 가까운 여행',
          action: '전체 보기',
          onAction: onViewAll,
        ),
        if (trip == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('다가오는 여행이 없어요. 새 여행을 만들어 보세요.'),
          )
        else
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: context.symmetricInsets(horizontal: 18, vertical: 20),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home_active_trip.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0xEE092621),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homeTripStatus(trip, data.now),
                    style: TextStyle(
                      color: const Color(0xFFBEEDE1),
                      fontSize: context.rs(12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const ResponsiveGap(height: 6),
                  Text(
                    trip.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rs(20),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const ResponsiveGap(height: 6),
                  Text(
                    [
                      if (trip.destination != null) trip.destination!,
                      homeTripPeriod(trip),
                    ].join(' · '),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.rs(11),
                    ),
                  ),
                  const ResponsiveGap(height: 6),
                  Text(
                    '일정 ${schedules?.length ?? '—'}개 · 예약 ${schedules?.where((s) => s.category == '예약').length ?? '—'}건 · 참여 ${members?.length ?? '—'}명',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.rs(11),
                    ),
                  ),
                  if (members != null && members.isNotEmpty) ...[
                    const ResponsiveGap(height: 8),
                    Wrap(
                      spacing: context.rs(5),
                      children: [
                        for (final member in members.take(4))
                          CircleAvatar(
                            radius: context.rs(13),
                            backgroundColor: const Color(0xFFDDF3EE),
                            child: Text(
                              member.nickname.characters.firstOrNull ?? '?',
                              style: TextStyle(fontSize: context.rs(10)),
                            ),
                          ),
                        if (members.length > 4)
                          Text(
                            '+${members.length - 4}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
