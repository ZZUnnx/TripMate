import 'package:flutter/material.dart';

import '../common/responsive.dart';

// 하단 네비게이션 바
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    this.currentIndex = 0,
    this.onItemSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onItemSelected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.rs(38));

    return Container(
      height: context.rs(76),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0x22000000),
            blurRadius: context.rs(26),
            offset: Offset(0, context.rs(10)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.white,
          child: Padding(
            padding: context.symmetricInsets(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: '홈',
                  isActive: currentIndex == 0,
                  onTap: () => onItemSelected?.call(0),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '채팅',
                  isActive: currentIndex == 1,
                  onTap: () => onItemSelected?.call(1),
                ),
                _NavItem(
                  icon: Icons.calendar_today_outlined,
                  label: '캘린더',
                  isActive: currentIndex == 2,
                  onTap: () => onItemSelected?.call(2),
                ),
                _NavItem(
                  icon: Icons.payments_outlined,
                  label: '정산',
                  isActive: currentIndex == 3,
                  onTap: () => onItemSelected?.call(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF635BFF) : const Color(0xFF9AA1B3);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(28)),
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: context.rs(28)),
                const ResponsiveGap(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: context.rs(12),
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
