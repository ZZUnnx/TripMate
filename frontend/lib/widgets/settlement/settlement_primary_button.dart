import 'package:flutter/material.dart';

import '../common/responsive.dart';

class SettlementPrimaryButton extends StatelessWidget {
  const SettlementPrimaryButton({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF148776),
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rs(12)),
        child: SizedBox(
          height: context.rs(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: context.rs(17),
              ),
              const ResponsiveGap(width: 7),
              Text(
                '정산 결과 확인',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rs(14),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
