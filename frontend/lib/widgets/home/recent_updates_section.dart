import 'package:flutter/material.dart';

import '../common/card_decoration.dart';
import '../common/responsive.dart';
import '../common/section_header.dart';

// 최근 업데이트 영역
class RecentUpdatesSection extends StatelessWidget {
  const RecentUpdatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SectionHeader(title: '최근 업데이트', actionLabel: '전체 보기'),
        ResponsiveGap(height: 10),
        _UpdatesCard(),
      ],
    );
  }
}

// 최근 업데이트 리스트 카드
class _UpdatesCard extends StatelessWidget {
  const _UpdatesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(context),
      child: const Column(
        children: [
          _UpdateItem(
            title: '김서연님이 오타루 일정을 추가했어요.',
            detail: '오타루 운하 산책 · 9/13 (금)',
            time: '2시간 전',
            avatar: _PersonAvatar(
              background: Color(0xFFE8C6A6),
              hair: Color(0xFF5E4739),
              face: Color(0xFFFFE2C6),
            ),
          ),
          _DividerLine(),
          _UpdateItem(
            title: '박민수님이 렌터카 정산을 요청했어요.',
            detail: '"렌터카 2일치 ₩70,000"',
            time: '5시간 전',
            avatar: _PersonAvatar(
              background: Color(0xFFE6E9F1),
              hair: Color(0xFF222936),
              face: Color(0xFFF0C8A8),
            ),
          ),
          _DividerLine(),
          _UpdateItem(
            title: '숙소 예약이 확정되었어요.',
            detail: '제주 하얏트 리젠시 · 9/12 - 9/15',
            time: '어제',
            avatar: _IconAvatar(icon: Icons.hotel_rounded),
          ),
          _DividerLine(),
          _UpdateItem(
            title: '항공권 일정이 추가되었어요.',
            detail: '김포 > 제주 · 9/12 (목) 10:20',
            time: '어제',
            avatar: _IconAvatar(icon: Icons.flight_takeoff_rounded),
          ),
        ],
      ),
    );
  }
}

// 최근 업데이트 항목
class _UpdateItem extends StatelessWidget {
  const _UpdateItem({
    required this.title,
    required this.detail,
    required this.time,
    required this.avatar,
  });

  final String title;
  final String detail;
  final String time;
  final Widget avatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.symmetricInsets(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          const ResponsiveGap(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF121827),
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const ResponsiveGap(height: 4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF8F96A8),
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const ResponsiveGap(width: 8),
          Text(
            time,
            style: TextStyle(
              color: const Color(0xFF9AA1B3),
              fontSize: context.rs(13),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.background,
    required this.hair,
    required this.face,
  });

  final Color background;
  final Color hair;
  final Color face;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(48),
      height: context.rs(48),
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: context.rs(8),
            child: Container(
              width: context.rs(28),
              height: context.rs(30),
              decoration: BoxDecoration(color: hair, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            top: context.rs(15),
            child: Container(
              width: context.rs(21),
              height: context.rs(22),
              decoration: BoxDecoration(color: face, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: context.rs(4),
            child: Container(
              width: context.rs(30),
              height: context.rs(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2FA),
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

class _IconAvatar extends StatelessWidget {
  const _IconAvatar({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(48),
      height: context.rs(48),
      decoration: const BoxDecoration(
        color: Color(0xFFECE8FF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF635BFF), size: context.rs(26)),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.rs(72)),
      child: const Divider(height: 1, thickness: 1, color: Color(0xFFEDEFF5)),
    );
  }
}
