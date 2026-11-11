import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/ai_summary_controller.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/models/settlement.dart';
import 'package:frontend/widgets/calendar/presentation/calendar_view_data.dart';

import '../fixtures/settlement_fixture.dart';

Map<String, dynamic> _item(String title, {String? date = '2026-10-31'}) => {
  'type': 'SCHEDULE',
  'title': title,
  'date': date,
  'time': '09:30',
  'placeName': 'place',
  'description': 'memo',
  'url': 'https://example.com',
};

void main() {
  ExpenseDraft expense({String title = '식사', int amount = 10000}) =>
      ExpenseDraft(
        title: title,
        amount: amount,
        payerId: 1,
        date: DateTime(2026, 10, 31),
        participantIds: const [2, 1],
        placeName: '식당',
      );

  test(
    'saves confirmed settlement and reservation amounts with schedules',
    () async {
      final expenses = <ExpenseDraft>[];
      final schedules = <CalendarScheduleDraft>[];
      final controller = AiSummaryController(
        tripId: 42,
        accessToken: 'token',
        items: [
          _item('tour'),
          {..._item('hotel'), 'type': 'RESERVATION', 'amount': 80000},
          {'type': 'SETTLEMENT', 'title': '식사', 'amount': 10000},
          {'type': 'SETTLEMENT', 'title': '미확인', 'amount': null},
        ],
        scheduleLoader: () async => [],
        settlementLoader: () async =>
            settlementFixture(tripId: 42, empty: true),
        scheduleCreator: (draft) async => schedules.add(draft),
        expenseCreator: (draft) async => expenses.add(draft),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.isExpenseCandidate(1), isTrue);
      expect(controller.pendingCount, 2);
      controller.confirmExpense(1, expense(title: 'hotel', amount: 80000));
      controller.confirmExpense(2, expense());
      expect(controller.pendingCount, 4);
      final result = await controller.saveSchedules();
      expect(result!.savedCount, 4);
      expect(result.remainingCount, 0);
      expect(controller.savedExpenseCount, 2);
      expect(schedules.map((s) => s.tripId), [42, 42]);
      expect(expenses.map((e) => e.amount), [80000, 10000]);
      expect(expenses.last.toJson()['participantIds'], [2, 1]);
      expect(await controller.saveSchedules(), isNull);
    },
  );

  test('existing and repeated expenses are excluded, and excluded drafts stay unsaved', () async {
    var calls = 0;
    final controller = AiSummaryController(
      tripId: 1,
      accessToken: 'token',
      items: List.generate(4, (_) => {'type': 'SETTLEMENT', 'title': '식사'}),
      scheduleLoader: () async => [],
      settlementLoader: () async => settlementFixture(),
      expenseCreator: (_) async => calls++,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    controller.confirmExpense(0, expense());
    controller.confirmExpense(1, expense(amount: 20000));
    controller.confirmExpense(2, expense(amount: 20000));
    controller.confirmExpense(3, expense(amount: 30000));
    controller.removeExpense(3);
    final result = await controller.saveSchedules();
    expect(calls, 1);
    expect(result!.savedCount, 1);
    expect(controller.existingExpenseCount, 2);
    expect(result.remainingCount, 0);
  });

  test('expense retry preserves saved schedules and expenses', () async {
    var scheduleCalls = 0;
    final attempts = <int>[];
    var fail = true;
    final controller = AiSummaryController(
      tripId: 1,
      accessToken: 'token',
      items: [
        _item('tour'),
        {'type': 'SETTLEMENT'},
        {'type': 'SETTLEMENT'},
      ],
      scheduleLoader: () async => [],
      settlementLoader: () async => settlementFixture(empty: true),
      scheduleCreator: (_) async => scheduleCalls++,
      expenseCreator: (draft) async {
        attempts.add(draft.amount);
        if (draft.amount == 20000 && fail) throw StateError('offline');
      },
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    controller.confirmExpense(1, expense());
    controller.confirmExpense(2, expense(amount: 20000));
    final partial = await controller.saveSchedules();
    expect(partial!.savedCount, 2);
    expect(partial.remainingCount, 1);
    expect(partial.error, isNotNull);
    fail = false;
    final result = await controller.saveSchedules();
    expect(result!.savedCount, 3);
    expect(result.remainingCount, 0);
    expect(scheduleCalls, 1);
    expect(attempts, [10000, 20000, 20000]);
  });

  test('lost expense response is reconciled with server on retry', () async {
    var calls = 0;
    final controller = AiSummaryController(
      tripId: 1,
      accessToken: 'token',
      items: [
        {'type': 'SETTLEMENT'},
      ],
      scheduleLoader: () async => [],
      settlementLoader: () async => settlementFixture(empty: calls == 0),
      expenseCreator: (_) async {
        calls++;
        throw StateError('lost response');
      },
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    controller.confirmExpense(0, expense());
    expect((await controller.saveSchedules())!.error, isNotNull);
    final retry = await controller.saveSchedules();
    expect(retry!.error, isNull);
    expect(retry.remainingCount, 0);
    expect(controller.existingExpenseCount, 1);
    expect(calls, 1);
  });

  TripSchedule existing(String title) => TripSchedule(
    id: 1,
    tripId: 1,
    tripTitle: 'trip',
    title: title,
    scheduledDate: DateTime(2026, 10, 31),
    scheduledTime: '09:30:00',
    placeName: 'place',
    category: 'shared',
    sortOrder: 0,
  );

  test(
    'reopening summary excludes existing items and suspects require selection',
    () async {
      final saved = <String>[];
      final controller = AiSummaryController(
        tripId: 1,
        accessToken: 'token',
        items: [
          _item(' lunch '),
          _item('meal'),
          {..._item('tour'), 'time': '10:00'},
        ],
        scheduleLoader: () async => [existing('l u n c h')],
        scheduleCreator: (draft) async => saved.add(draft.title),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.isExisting(0), isTrue);
      expect(controller.isSelected(0), isFalse);
      expect(controller.isSuspected(1), isTrue);
      expect(controller.isSelected(1), isFalse);
      controller.select(0, true);
      expect(controller.isSelected(0), isFalse);
      controller.select(1, true);
      final result = await controller.saveSchedules();
      expect(saved, ['meal', 'tour']);
      expect(result!.existingCount, 1);
      expect(result.savedCount, 2);
    },
  );

  test(
    'server duplicates and repeated candidates are excluded from saved count',
    () async {
      var calls = 0;
      final controller = AiSummaryController(
        tripId: 1,
        accessToken: 'token',
        items: [_item('tour'), _item(' tour ')],
        scheduleLoader: () async => [],
        scheduleImporter: (_) async {
          calls++;
          return false;
        },
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      final result = await controller.saveSchedules();
      expect(calls, 1);
      expect(result!.savedCount, 0);
      expect(result.existingCount, 2);
      expect(result.remainingCount, 0);
    },
  );

  test('failed lookup blocks saving and retry restores selection', () async {
    var fail = true;
    var calls = 0;
    final controller = AiSummaryController(
      tripId: 1,
      accessToken: 'token',
      items: [_item('tour')],
      scheduleLoader: () async {
        if (fail) throw StateError('offline');
        return [];
      },
      scheduleCreator: (_) async => calls++,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(controller.loadError, isNotNull);
    expect(await controller.saveSchedules(), isNull);
    expect(calls, 0);
    fail = false;
    await controller.initialize();
    controller.select(0, false);
    expect(await controller.saveSchedules(), isNull);
    controller.select(0, true);
    await controller.saveSchedules();
    expect(calls, 1);
  });

  test('maps dated schedules and reservations to the current trip', () async {
    final saved = <CalendarScheduleDraft>[];
    final controller = AiSummaryController(
      tripId: 42,
      scheduleLoader: () async => [],
      accessToken: 'token',
      items: [
        _item('tour'),
        {
          ..._item('hotel'),
          'type': 'RESERVATION',
          'endDate': '2026-11-02',
          'time': null,
        },
        {..._item('expense'), 'type': 'SETTLEMENT'},
        _item('unknown date', date: null),
      ],
      scheduleCreator: (draft) async => saved.add(draft),
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(controller.eligibleCount, 2);
    expect(controller.skippedCount, 1);
    final result = await controller.saveSchedules();
    expect(result!.savedCount, 2);
    expect(result.remainingCount, 0);
    expect(result.error, isNull);
    expect(saved.map((draft) => draft.tripId), [42, 42]);
    expect(saved.first.scheduledDate, DateTime(2026, 10, 31));
    expect(saved.first.scheduledTime, '09:30:00');
    expect(saved.first.placeName, 'place');
    expect(saved.first.url, 'https://example.com');
    expect(saved.first.description, 'memo');
    expect(saved.last.category, '예약');
    expect(saved.last.scheduledTime, isNull);
    expect(saved.last.description, contains('2026-11-02'));
  });

  test(
    'excludes invalid dates, titles, times, and reversed reservation ranges',
    () async {
      var calls = 0;
      final controller = AiSummaryController(
        tripId: 1,
        scheduleLoader: () async => [],
        accessToken: 'token',
        items: [
          _item('invalid day', date: '2026-02-30'),
          _item('missing year', date: '10-31'),
          _item('  '),
          {..._item('invalid time'), 'time': '25:00'},
          {..._item('hotel'), 'type': 'RESERVATION', 'endDate': '2026-10-30'},
          {..._item('expense'), 'type': 'SETTLEMENT'},
          null,
        ],
        scheduleCreator: (_) async => calls++,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.pendingCount, 0);
      expect(controller.skippedCount, 5);
      expect(await controller.saveSchedules(), isNull);
      expect(calls, 0);
    },
  );

  test(
    'does not save successful items again when retrying a partial failure',
    () async {
      final attempts = <String>[];
      var fail = true;
      final controller = AiSummaryController(
        tripId: 1,
        scheduleLoader: () async => [],
        accessToken: 'token',
        items: [_item('first'), _item('second'), _item('third')],
        scheduleCreator: (draft) async {
          attempts.add(draft.title);
          if (draft.title == 'second' && fail) throw StateError('offline');
        },
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      final partial = await controller.saveSchedules();
      expect(partial!.savedCount, 1);
      expect(partial.remainingCount, 2);
      expect(partial.error, isA<StateError>());
      expect(controller.isSaving, isFalse);
      fail = false;
      final retry = await controller.saveSchedules();
      expect(retry!.savedCount, 3);
      expect(retry.remainingCount, 0);
      expect(retry.error, isNull);
      expect(attempts, ['first', 'second', 'second', 'third']);
      expect(await controller.saveSchedules(), isNull);
    },
  );

  test('prevents concurrent submissions and stops after disposal', () async {
    final pending = Completer<void>();
    var calls = 0;
    var notifications = 0;
    final controller = AiSummaryController(
      tripId: 1,
      scheduleLoader: () async => [],
      accessToken: 'token',
      items: [_item('first'), _item('second')],
      scheduleCreator: (_) {
        calls++;
        return pending.future;
      },
    );
    await controller.initialize();
    controller.addListener(() => notifications++);
    final first = controller.saveSchedules();
    expect(controller.isSaving, isTrue);
    expect(await controller.saveSchedules(), isNull);
    controller.dispose();
    pending.complete();
    await first;
    expect(calls, 1);
    expect(notifications, 1);
  });
}
