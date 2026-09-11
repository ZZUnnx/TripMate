import 'package:flutter/material.dart';

import '../common/responsive.dart';

class SettlementResultSheet extends StatelessWidget {
  const SettlementResultSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: context.insetsFromLTRB(24, 10, 24, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(24)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.rs(42),
              height: context.rs(5),
              decoration: BoxDecoration(
                color: const Color(0xFFDADDF0),
                borderRadius: BorderRadius.circular(context.rs(20)),
              ),
            ),
            const ResponsiveGap(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.rs(58),
                  height: context.rs(58),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7468FF), Color(0xFF9F77F2)],
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: context.rs(34),
                  ),
                ),
                const ResponsiveGap(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '최종 정산 결과',
                        style: TextStyle(
                          color: const Color(0xFF060914),
                          fontSize: context.rs(20),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const ResponsiveGap(height: 8),
                      Text(
                        '아래와 같이 정산하면 완료돼요!',
                        style: TextStyle(
                          color: const Color(0xFF76809A),
                          fontSize: context.rs(14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: const Color(0xFFF0F2F7),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: context.rs(36),
                      height: context.rs(36),
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFF424969),
                        size: context.rs(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const ResponsiveGap(height: 26),
            const _TransferRow(
              name: '민수',
              amount: '₩62,000',
              color: Color(0xFFF05A7A),
            ),
            const _SheetDivider(),
            const _TransferRow(
              name: '서연',
              amount: '₩42,000',
              color: Color(0xFF5D8BFF),
            ),
            const _SheetDivider(),
            const _TransferRow(
              name: '현우',
              amount: '₩34,000',
              color: Color(0xFF45B878),
            ),
            const ResponsiveGap(height: 24),
            Container(
              padding: context.symmetricInsets(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0ECFF),
                borderRadius: BorderRadius.circular(context.rs(12)),
              ),
              child: Row(
                children: [
                  const ResponsiveIcon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFF635BFF),
                    size: 24,
                  ),
                  const ResponsiveGap(width: 12),
                  Expanded(
                    child: Text(
                      '카카오페이로 간편하게 송금할 수 있어요!',
                      style: TextStyle(
                        color: const Color(0xFF3E4354),
                        fontSize: context.rs(13),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const ResponsiveIcon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF8990A5),
                    size: 22,
                  ),
                ],
              ),
            ),
            const ResponsiveGap(height: 22),
            _PrimarySheetButton(
              label: '정산 완료',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({
    required this.name,
    required this.amount,
    required this.color,
  });

  final String name;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.symmetricInsets(vertical: 12),
      child: Row(
        children: [
          Container(
            width: context.rs(36),
            height: context.rs(36),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: color,
              size: context.rs(22),
            ),
          ),
          const ResponsiveGap(width: 14),
          Text(
            name,
            style: TextStyle(
              color: const Color(0xFF060914),
              fontSize: context.rs(15),
              fontWeight: FontWeight.w900,
            ),
          ),
          const ResponsiveGap(width: 14),
          const ResponsiveIcon(
            Icons.arrow_forward_rounded,
            color: Color(0xFF5F6680),
            size: 22,
          ),
          const ResponsiveGap(width: 14),
          Text(
            '준영',
            style: TextStyle(
              color: const Color(0xFF060914),
              fontSize: context.rs(15),
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              color: const Color(0xFF060914),
              fontSize: context.rs(15),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEDEFF5));
  }
}

class _PrimarySheetButton extends StatelessWidget {
  const _PrimarySheetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: Ink(
          height: context.rs(58),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.rs(12)),
            gradient: const LinearGradient(
              colors: [Color(0xFF7468FF), Color(0xFF635BFF)],
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rs(16),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
