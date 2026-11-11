import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/ai_summary_controller.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/models/settlement.dart';
import 'package:frontend/widgets/chat/detail/ai_summary_sheet.dart';

import '../fixtures/settlement_fixture.dart';

void main() {
  testWidgets('reviews AI amount before saving it to settlement', (
    tester,
  ) async {
    final saved = <ExpenseDraft>[];
    final controller = AiSummaryController(
      tripId: 42,
      accessToken: 'test',
      items: [
        {
          'type': 'SETTLEMENT',
          'title': '숙소비',
          'amount': 80000,
          'date': '2026-10-31',
          'placeName': '호텔',
          'peopleCount': 1,
        },
      ],
      scheduleLoader: () async => [],
      settlementLoader: () async => settlementFixture(tripId: 42, empty: true),
      expenseCreator: (draft) async => saved.add(draft),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<int>(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    AiSummarySheet(controller: controller, currentUserId: 2),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('확인'));
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '80000'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '숙소비'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, '80000'),
      '90000',
    );
    await tester.ensureVisible(find.text('요약에 반영'));
    await tester.tap(find.text('요약에 반영'));
    await tester.pumpAndSettle();
    expect(saved, isEmpty);
    expect(controller.pendingExpenseCount, 1);
    await tester.ensureVisible(find.text('선택한 일정·정산 저장'));
    await tester.tap(find.text('선택한 일정·정산 저장'));
    await tester.pumpAndSettle();
    expect(saved.single.title, '숙소비');
    expect(saved.single.amount, 90000);
    expect(saved.single.payerId, 2);
    expect(saved.single.participantIds, [1, 2]);
    expect(saved.single.date, DateTime(2026, 10, 31));
    expect(saved.single.placeName, '호텔');
    expect(tester.takeException(), isNull);
  });

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
    await tester.ensureVisible(find.text('선택한 일정·정산 저장'));
    await tester.tap(find.text('선택한 일정·정산 저장'));
    await tester.pump();
    expect(calls, 0);
    expect(find.textContaining('1개는 제외됩니다'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
