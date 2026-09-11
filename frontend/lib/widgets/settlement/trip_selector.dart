import 'package:flutter/material.dart';

import '../common/responsive.dart';

class TripSelector extends StatelessWidget {
  const TripSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _TripChip(
            icon: '🏝️',
            title: '제주도 여행',
            date: '9.12 - 9.15',
            isSelected: true,
          ),
        ),
        ResponsiveGap(width: 10),
        Expanded(
          child: _TripChip(icon: '🌊', title: '부산 여행', date: '8.20 - 8.22'),
        ),
        ResponsiveGap(width: 10),
        Expanded(child: _AddTripChip()),
      ],
    );
  }
}

class _TripChip extends StatelessWidget {
  const _TripChip({
    required this.icon,
    required this.title,
    required this.date,
    this.isSelected = false,
  });

  final String icon;
  final String title;
  final String date;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(72),
      padding: context.symmetricInsets(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(context.rs(10)),
        border: Border.all(
          color: isSelected ? const Color(0xFF8B7CFF) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: context.rs(24))),
          const ResponsiveGap(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF121827),
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const ResponsiveGap(height: 6),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF76809A),
                    fontSize: context.rs(12),
                    fontWeight: FontWeight.w700,
                    height: 1,
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

class _AddTripChip extends StatelessWidget {
  const _AddTripChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(72),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_rounded,
            color: const Color(0xFF5F6680),
            size: context.rs(24),
          ),
          const ResponsiveGap(height: 6),
          Text(
            '여행 추가',
            style: TextStyle(
              color: const Color(0xFF76809A),
              fontSize: context.rs(12),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
