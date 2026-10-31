import 'package:flutter/material.dart';

import '../common/responsive.dart';

class CalendarEmptyAgendaCard extends StatelessWidget {
  const CalendarEmptyAgendaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.symmetricInsets(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.rs(12)),
      ),
      child: Text(
        '등록된 일정이 없어요.',
        style: TextStyle(
          color: const Color(0xFF60706D),
          fontSize: context.rs(12),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
