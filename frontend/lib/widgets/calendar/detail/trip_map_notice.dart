import 'package:flutter/material.dart';

import '../../common/responsive.dart';

class TripMapNotice extends StatelessWidget {
  const TripMapNotice({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF3F2),
      borderRadius: BorderRadius.circular(context.rs(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(10)),
        child: SizedBox(
          height: context.rs(32),
          child: Padding(
            padding: context.symmetricInsets(horizontal: 11),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  color: const Color(0xFF60706D),
                  size: context.rs(14),
                ),
                const ResponsiveGap(width: 7),
                Text(
                  '지도에서 보기',
                  style: TextStyle(
                    color: const Color(0xFF60706D),
                    fontSize: context.rs(11),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const ResponsiveGap(width: 4),
                Text(
                  '· 준비 중',
                  style: TextStyle(
                    color: const Color(0xFF8A9895),
                    fontSize: context.rs(10),
                    fontWeight: FontWeight.w400,
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
