import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/calendar/calendar_controller.dart';
import 'package:frontend/controllers/calendar/trip_calendar_detail_controller.dart';
import 'package:frontend/models/trip_schedule.dart';

TripSchedule _schedule(int id) => TripSchedule(
  id: id,
  tripId: 7,
  tripTitle: 'trip',
  title: 'schedule $id',
  scheduledDate: DateTime(2026, 10, 31),
  category: 'shared',
  sortOrder: id,
);

void main() {
  test('calendar deletes once and refreshes only after success', () async {
    final pending = Completer<void>();
    var loads = 0;
    var deletes = 0;
    final controller = CalendarController(
      tripLoader: (_) async {
        loads++;
        return [];
      },
      scheduleDeleter: (token, id) {
        expect(token, 'token');
        expect(id, 42);
        deletes++;
        return pending.future;
      },
    );
    addTearDown(controller.dispose);
    controller.updateSession(isInitialized: true, accessToken: 'token');
    await controller.calendarFuture;
    final result = controller.deleteSchedule(42);
    expect(controller.deletingIds, {42});
    expect(await controller.deleteSchedule(42), isFalse);
    expect(loads, 1);
    pending.complete();
    expect(await result, isTrue);
    await controller.calendarFuture;
    expect(loads, 2);
    expect(deletes, 1);
    expect(controller.deletingIds, isEmpty);
  });

  test('calendar failed deletion retains the current data request', () async {
    final controller = CalendarController(
      tripLoader: (_) async => [],
      scheduleDeleter: (_, _) async => throw StateError('denied'),
    );
    addTearDown(controller.dispose);
    controller.updateSession(isInitialized: true, accessToken: 'token');
    final request = controller.calendarFuture;
    await request;
    await expectLater(controller.deleteSchedule(1), throwsStateError);
    expect(controller.calendarFuture, same(request));
    expect(controller.deletingIds, isEmpty);
  });

  test(
    'detail retains failed items and updates count and timeline after retry',
    () async {
      var fail = true;
      final original = [_schedule(1), _schedule(2)];
      final controller = TripCalendarDetailController(
        schedules: original,
        selectedSchedule: original.first,
        memberLoader: (_, _) async => [],
        scheduleDeleter: (_, _) async {
          if (fail) throw StateError('offline');
        },
      );
      addTearDown(controller.dispose);
      controller.updateSession('token');
      await controller.membersFuture;
      await expectLater(controller.deleteSchedule(1), throwsStateError);
      expect(controller.scheduleCount, 2);
      expect(controller.deletingIds, isEmpty);
      fail = false;
      expect(await controller.deleteSchedule(1), isTrue);
      expect(controller.scheduleCount, 1);
      expect(controller.timelineSections.single.items.single.schedule.id, 2);
      expect(await controller.deleteSchedule(1), isFalse);
      expect(await controller.deleteSchedule(2), isTrue);
      expect(controller.timelineSections, isEmpty);
      expect(controller.scheduleCount, 0);
      expect(original.length, 2);
    },
  );

  test(
    'detail blocks duplicate requests and ignores completion after disposal',
    () async {
      final pending = Completer<void>();
      var calls = 0;
      var notifications = 0;
      final controller = TripCalendarDetailController(
        schedules: [_schedule(1)],
        selectedSchedule: _schedule(1),
        memberLoader: (_, _) async => [],
        scheduleDeleter: (_, _) {
          calls++;
          return pending.future;
        },
      );
      controller.updateSession('token');
      await controller.membersFuture;
      controller.addListener(() => notifications++);
      final result = controller.deleteSchedule(1);
      expect(await controller.deleteSchedule(1), isFalse);
      controller.dispose();
      pending.complete();
      await result;
      expect(calls, 1);
      expect(notifications, 1);
    },
  );

  test('deletion requires a logged-in session', () async {
    var calls = 0;
    final controller = CalendarController(
      scheduleDeleter: (_, _) async => calls++,
    );
    addTearDown(controller.dispose);
    await expectLater(controller.deleteSchedule(1), throwsStateError);
    expect(calls, 0);
  });
}
