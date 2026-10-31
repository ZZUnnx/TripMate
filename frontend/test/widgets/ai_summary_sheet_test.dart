import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/ai_summary_controller.dart';
import 'package:frontend/widgets/chat/detail/ai_summary_sheet.dart';

void main() {
  testWidgets('adds the current summary and returns the saved count', (
    tester,
  ) async {
    final pending = Completer<void>();
    var calls = 0;
    int? result;
    final controller = AiSummaryController(
      tripId: 42,
      accessToken: 'test',
      items: [
        {'type': 'SCHEDULE', 'title': 'tour', 'date': '2026-10-31'},
      ],
      scheduleCreator: (draft) {
        expect(draft.tripId, 42);
        calls++;
        return pending.future;
      },
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<int>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AiSummarySheet(controller: controller),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('1개 정보를 찾았어요'), findsOneWidget);
    await tester.ensureVisible(find.text('공유 일정에 추가'));
    await tester.tap(find.text('공유 일정에 추가'));
    await tester.pump();
    expect(find.text('저장 중...'), findsOneWidget);
    await tester.tap(find.text('저장 중...'));
    await tester.pump();
    expect(calls, 1);
    expect(find.byType(AiSummarySheet), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(result, 1);
    expect(find.byType(AiSummarySheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not submit when no dated calendar items are available', (
    tester,
  ) async {
    var calls = 0;
    final controller = AiSummaryController(
      tripId: 1,
      accessToken: 'test',
      items: [
        {'type': 'SCHEDULE', 'title': 'unknown date', 'date': null},
        {'type': 'SETTLEMENT', 'title': 'expense', 'amount': 10000},
      ],
      scheduleCreator: (_) async => calls++,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AiSummarySheet(controller: controller)),
      ),
    );
    await tester.ensureVisible(find.text('공유 일정에 추가'));
    await tester.tap(find.text('공유 일정에 추가'));
    await tester.pump();
    expect(calls, 0);
    expect(find.textContaining('1개는 제외됩니다'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
