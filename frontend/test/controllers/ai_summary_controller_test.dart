import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/ai_summary_controller.dart';
import 'package:frontend/widgets/calendar/presentation/calendar_view_data.dart';

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
  test('maps dated schedules and reservations to the current trip', () async {
    final saved = <CalendarScheduleDraft>[];
    final controller = AiSummaryController(
      tripId: 42,
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
        accessToken: 'token',
        items: [_item('first'), _item('second'), _item('third')],
        scheduleCreator: (draft) async {
          attempts.add(draft.title);
          if (draft.title == 'second' && fail) throw StateError('offline');
        },
      );
      addTearDown(controller.dispose);
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
      accessToken: 'token',
      items: [_item('first'), _item('second')],
      scheduleCreator: (_) {
        calls++;
        return pending.future;
      },
    );
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
