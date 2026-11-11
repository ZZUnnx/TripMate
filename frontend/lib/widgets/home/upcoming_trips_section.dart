import 'package:flutter/material.dart';

import '../../models/home_data.dart';
import '../../models/trip.dart';
import '../common/responsive.dart';
import 'home_section_header.dart';

class UpcomingTripsSection extends StatelessWidget {
  const UpcomingTripsSection({
    super.key,
    required this.data,
    this.onTripTap,
    this.onViewAll,
  });
  final HomeData data;
  final ValueChanged<Trip>? onTripTap;
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      HomeSectionHeader(title: '예정된 여행', action: '전체 보기', onAction: onViewAll),
      if (data.upcomingTrips.isEmpty)
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text('예정된 여행이 없습니다.'),
        ),
      for (final trip in data.upcomingTrips.take(5))
        InkWell(
          onTap: onTripTap == null ? null : () => onTripTap!(trip),
          child: _TripListItem(
            emoji: '✈',
            emojiBackground: const Color(0xFFDDF3EE),
            title: trip.title,
            status: trip.startDate == null ? '날짜 미정' : '예정',
            trailing: homeTripStatus(trip, data.now),
            description: [
              homeTripPeriod(trip),
              if (trip.destination != null) trip.destination!,
            ].join(' · '),
          ),
        ),
    ],
  );
}

class _TripListItem extends StatelessWidget {
  const _TripListItem({
    required this.emoji,
    required this.emojiBackground,
    required this.title,
    required this.status,
    required this.trailing,
    required this.description,
  });

  final String emoji;
  final Color emojiBackground;
  final String title;
  final String status;
  final String trailing;
  final String description;
  final Color statusColor = const Color(0xFF8A9895);
  final Color statusBackground = const Color(0xFFF0F5F4);
  final bool muted = false;

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
