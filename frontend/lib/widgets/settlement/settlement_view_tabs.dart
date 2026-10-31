import 'package:flutter/material.dart';

import '../common/responsive.dart';

enum SettlementView { overview, payer, place }

class SettlementViewTabs extends StatelessWidget {
  const SettlementViewTabs({
    super.key,
    required this.selectedView,
    required this.onChanged,
  });

  final SettlementView selectedView;
  final ValueChanged<SettlementView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.rs(34),
      padding: EdgeInsets.all(context.rs(3)),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F2),
        borderRadius: BorderRadius.circular(context.rs(10)),
      ),
      child: Row(
        children: [
          _SettlementTab(
            label: '한눈에',
            isActive: selectedView == SettlementView.overview,
            onTap: () => onChanged(SettlementView.overview),
          ),
          _SettlementTab(
            label: '결제자별',
            isActive: selectedView == SettlementView.payer,
            onTap: () => onChanged(SettlementView.payer),
          ),
          _SettlementTab(
            label: '장소별',
            isActive: selectedView == SettlementView.place,
            onTap: () => onChanged(SettlementView.place),
          ),
        ],
      ),
    );
  }
}

class _SettlementTab extends StatelessWidget {
  const _SettlementTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(context.rs(8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(8)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF0B5F55)
                    : const Color(0xFF60706D),
                fontSize: context.rs(11),
                fontWeight: isActive ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
