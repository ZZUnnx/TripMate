import 'package:flutter/material.dart';

import '../calendar_circle_button.dart';
import '../../common/responsive.dart';

class TripCalendarHeader extends StatelessWidget {
  const TripCalendarHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onAdd,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Row(
        children: [
          CalendarCircleButton(
            icon: Icons.chevron_left_rounded,
            iconSize: 20,
            onTap: onBack,
          ),
          const ResponsiveGap(width: 10),
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
                    color: const Color(0xFF152523),
                    fontSize: context.rs(18),
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                  ),
                ),
                const ResponsiveGap(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: const Color(0xFF148776),
            borderRadius: BorderRadius.circular(context.rs(999)),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(context.rs(999)),
              child: Padding(
                padding: context.symmetricInsets(horizontal: 11, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: context.rs(13),
                    ),
                    const ResponsiveGap(width: 4),
                    Text(
                      '일정 추가',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rs(10),
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
