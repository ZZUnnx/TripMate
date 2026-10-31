import 'package:flutter/material.dart';

import '../common/responsive.dart';

class SettlementTopHeader extends StatelessWidget {
  const SettlementTopHeader({
    super.key,
    this.title = '여행 정산',
    this.subtitle = '제주 봄 여행 · 여행 종료',
    this.onBack,
    this.showDownload = true,
    this.onDownload,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final bool showDownload;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.rs(58),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              tooltip: '여행 목록으로',
              onPressed: onBack,
              icon: const Icon(Icons.chevron_left_rounded),
              color: const Color(0xFF152523),
            ),
            const ResponsiveGap(width: 4),
          ],
          if (onBack == null)
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
          const ResponsiveGap(width: 12),
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
                    height: 1.1,
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
                  ),
                ),
              ],
            ),
          ),
          if (showDownload)
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: Tooltip(
                message: '지출 CSV 복사',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onDownload,
                  child: SizedBox(
                    width: context.rs(34),
                    height: context.rs(34),
                    child: Icon(
                      Icons.copy_outlined,
                      color: const Color(0xFF152523),
                      size: context.rs(18),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
