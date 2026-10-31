import 'package:flutter/material.dart';

import '../common/responsive.dart';

class HomeTopHeader extends StatelessWidget {
  const HomeTopHeader({super.key});

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
