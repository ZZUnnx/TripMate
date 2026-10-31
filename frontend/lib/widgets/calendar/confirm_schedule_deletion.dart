import 'package:flutter/material.dart';

Future<bool> confirmScheduleDeletion(BuildContext context, String title) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('일정 삭제'),
          content: Text('“$title” 일정을 삭제할까요?\n공유 일정에서 삭제되며 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('삭제'),
            ),
          ],
        ),
      ) ??
      false;
}
