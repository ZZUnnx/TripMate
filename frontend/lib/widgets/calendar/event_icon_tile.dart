import 'package:flutter/material.dart';

import '../common/responsive.dart';
import 'calendar_event.dart';

class EventIconTile extends StatelessWidget {
  const EventIconTile({required this.event, super.key});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.rs(45),
      height: context.rs(45),
      decoration: BoxDecoration(
        color: event.backgroundColor,
        borderRadius: BorderRadius.circular(context.rs(9)),
      ),
      child: Icon(event.icon, color: event.color, size: context.rs(24)),
    );
  }
}
