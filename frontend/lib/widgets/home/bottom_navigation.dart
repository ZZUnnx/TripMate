import 'package:flutter/material.dart';

import '../common/responsive.dart';

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
    return Container(
      height: context.rs(70),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDCE6E3))),
      ),
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: context.insetsFromLTRB(24, 9, 24, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
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
                icon: Icons.calendar_month_outlined,
                label: '캘린더',
                isActive: currentIndex == 2,
                onTap: () => onItemSelected?.call(2),
              ),
              _NavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: '정산',
                isActive: currentIndex == 3,
                onTap: () => onItemSelected?.call(3),
              ),
            ],
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
    final color = isActive ? const Color(0xFF0B5F55) : const Color(0xFF8A9895);

    return SizedBox(
      width: context.rs(54),
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(12)),
          child: SizedBox(
            height: context.rs(51),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: context.rs(32),
                  height: context.rs(25),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFDDF3EE)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(context.rs(999)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: context.rs(17)),
                ),
                const ResponsiveGap(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: context.rs(10),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    height: 1.2,
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
