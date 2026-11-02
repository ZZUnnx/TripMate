import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/chat/ai_summary_controller.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/widgets/calendar/presentation/calendar_transformations.dart';
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
  test(
    'missing AI time does not duplicate an unchanged existing reservation',
    () async {
      final controller = AiSummaryController(
        tripId: 1,
        accessToken: 'token',
        items: [
          {'type': 'RESERVATION', 'title': '호텔 예약', 'date': '2026-10-31'},
        ],
        scheduleLoader: () async => [
          TripSchedule(
            id: 8,
            tripId: 1,
            tripTitle: 'trip',
            title: '호텔 예약',
            category: '예약',
            scheduledDate: DateTime(2026, 10, 31),
            scheduledTime: '14:00:00',
            description: '예약 비용: 240000원',
            sortOrder: 0,
          ),
        ],
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.isExisting(0), isTrue);
      expect(controller.isUpdate(0), isFalse);
      expect(controller.pendingCount, 0);
    },
  );

  test('existing reservation updates only after selection and preserves unknown fields', () async {
    final old = TripSchedule(
      id: 8,
      tripId: 1,
      tripTitle: 'trip',
      title: '호텔 예약',
      category: '예약',
      scheduledDate: DateTime(2026, 10, 31),
      scheduledTime: '14:00:00',
      placeName: '호텔',
      url: 'https://hotel.test',
      sortOrder: 3,
      description: '직접 작성한 메모\n예약 비용: 200000원\n예약 인원: 2명',
    );
    final updates = <TripSchedule>[];
    var creates = 0;
    var fail = true;
    final controller = AiSummaryController(
      tripId: 1,
      accessToken: 'token',
      items: [
        {
          'type': 'RESERVATION',
          'title': '호텔 예약',
          'date': '2026-11-01',
          'placeName': '호텔',
          'amount': 240000,
        },
      ],
      scheduleLoader: () async => [old],
      scheduleCreator: (_) async {
        creates++;
      },
      scheduleUpdater: (s) async {
        if (fail) throw StateError('network');
        updates.add(s);
      },
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(controller.isUpdate(0), isTrue);
    expect(controller.isSelected(0), isFalse);
    expect(controller.updatePreview(0), contains('240000원'));
    expect(await controller.saveSchedules(), isNull);
    controller.select(0, true);
    expect((await controller.saveSchedules())!.error, isNotNull);
    expect(controller.isSelected(0), isTrue);
    fail = false;
    expect((await controller.saveSchedules())!.savedCount, 1);
    expect(creates, 0);
    final updated = updates.single;
    expect(updated.id, old.id);
    expect(updated.scheduledDate, DateTime(2026, 11, 1));
    expect(updated.scheduledTime, old.scheduledTime);
    expect(updated.url, old.url);
    expect(updated.description, '직접 작성한 메모\n예약 인원: 2명\n예약 비용: 240000원');
    expect(calendarReservationCost(updated), '총 240,000원 · 2명');
    expect(await controller.saveSchedules(), isNull);
  });

  TripSchedule existing(String title) => TripSchedule(
    id: 1,
    tripId: 1,
    tripTitle: 'trip',
    title: title,
    scheduledDate: DateTime(2026, 10, 31),
    scheduledTime: '09:30:00',
    placeName: 'place',
    description: 'memo',
    url: 'https://example.com',
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
          'amount': 240000,
          'peopleCount': 2,
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
    expect(saved.last.description, contains('예약 비용: 240000원'));
    expect(saved.last.description, contains('예약 인원: 2명'));
    final restored = TripSchedule.fromJson({
      'id': 2,
      'tripId': 42,
      'tripTitle': 'trip',
      'title': saved.last.title,
      'category': saved.last.category,
      'scheduledDate': '2026-10-31',
      'description': saved.last.description,
    });
    expect(calendarTimelineEntryFromSchedule(restored).cost, '총 240,000원 · 2명');
    expect(calendarTimelineEntryFromSchedule(existing('tour')).cost, '비용 미정');
  });

  test(
    'reservation cost requires an explicit saved amount and supports zero',
    () {
      TripSchedule reservation(String? memo) => TripSchedule(
        id: 1,
        tripId: 1,
        tripTitle: 'trip',
        title: 'hotel',
        scheduledDate: DateTime(2026, 10, 31),
        category: '예약',
        sortOrder: 0,
        description: memo,
      );
      expect(calendarReservationCost(reservation(null)), '비용 미정');
      expect(calendarReservationCost(reservation('숙소비 240000원')), '비용 미정');
      expect(calendarReservationCost(reservation('예약 비용: 0원')), '총 0원');
      expect(
        calendarReservationCost(reservation('예약 비용: 90000원')),
        '총 90,000원',
      );
    },
  );

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
