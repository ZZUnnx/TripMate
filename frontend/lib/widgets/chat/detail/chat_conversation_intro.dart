import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../common/responsive.dart';

class ChatConversationIntro extends StatelessWidget {
  const ChatConversationIntro({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: context.symmetricInsets(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF3F2),
          borderRadius: BorderRadius.circular(context.rs(999)),
        ),
        child: Text(
          _dateLabel(message.sentAt),
          style: TextStyle(
            color: const Color(0xFF60706D),
            fontSize: context.rs(10),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 $weekday요일';
  }
}
