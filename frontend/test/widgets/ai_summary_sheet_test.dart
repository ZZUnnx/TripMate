import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/ai_summary_controller.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/widgets/chat/detail/ai_summary_sheet.dart';

void main() {
  testWidgets(
    'existing choice is locked and suspected choice needs selection',
    (tester) async {
      final controller = AiSummaryController(
        tripId: 1,
        accessToken: 'test',
        items: [
          {
            'type': 'SCHEDULE',
            'title': 'lunch',
            'date': '2026-10-31',
            'time': '12:00',
            'placeName': 'cafe',
          },
          {
            'type': 'SCHEDULE',
            'title': 'meal',
            'date': '2026-10-31',
            'time': '12:00',
            'placeName': 'cafe',
          },
        ],
        scheduleLoader: () async => [
          TripSchedule(
            id: 1,
            tripId: 1,
            tripTitle: 'trip',
            title: 'lunch',
            scheduledDate: DateTime(2026, 10, 31),
            scheduledTime: '12:00:00',
            placeName: 'cafe',
            category: 'shared',
            sortOrder: 0,
          ),
        ],
        scheduleCreator: (_) async {},
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AiSummarySheet(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();
      final existing = tester.widget<CheckboxListTile>(
        find.byKey(const ValueKey('schedule-choice-0')),
      );
      expect(existing.onChanged, isNull);
      expect(existing.value, isFalse);
      final suspected = find.byKey(const ValueKey('schedule-choice-1'));
      expect(tester.widget<CheckboxListTile>(suspected).value, isFalse);
      await tester.ensureVisible(suspected);
      await tester.tap(suspected);
      await tester.pump();
      expect(tester.widget<CheckboxListTile>(suspected).value, isTrue);
      expect(controller.pendingCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('adds the current summary and returns the saved count', (
    tester,
  ) async {
    final pending = Completer<void>();
    var calls = 0;
    int? result;
    final controller = AiSummaryController(
      tripId: 42,
      scheduleLoader: () async => [],
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
      scheduleLoader: () async => [],
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
