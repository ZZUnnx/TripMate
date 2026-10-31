import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/calendar/calendar_controller.dart';
import 'package:frontend/controllers/calendar/trip_calendar_detail_controller.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/widgets/calendar/presentation/calendar_view_data.dart';

TripSchedule _schedule(int id, int tripId, int day, String time) =>
    TripSchedule(
      id: id,
      tripId: tripId,
      tripTitle: 'trip $tripId',
      title: 'schedule $id',
      scheduledDate: DateTime(2026, 10, day),
      scheduledTime: time,
      category: 'sightseeing',
      sortOrder: 0,
    );

CalendarScheduleDraft _draft() => CalendarScheduleDraft(
  tripId: 1,
  title: 'new schedule',
  category: 'sightseeing',
  scheduledDate: DateTime(2026, 10, 31),
  scheduledTime: '12:00:00',
  placeName: 'place',
  url: 'https://example.com',
  description: 'memo',
);

void main() {
  test('combines all trips and sorts schedules by date and time', () async {
    final loadedTrips = <int>[];
    final controller = CalendarController(
      tripLoader: (_) async => [
        const Trip(id: 1, title: 'first'),
        const Trip(id: 2, title: 'second'),
      ],
      scheduleLoader: (_, tripId) async {
        loadedTrips.add(tripId);
        return tripId == 1
            ? [_schedule(1, 1, 31, '12:00:00'), _schedule(2, 1, 30, '15:00:00')]
            : [_schedule(3, 2, 30, '09:00:00')];
      },
    );
    addTearDown(controller.dispose);
    controller.updateSession(isInitialized: true, accessToken: 'test');
    final data = await controller.calendarFuture!;
    expect(loadedTrips, [1, 2]);
    expect(data.schedules.map((schedule) => schedule.id), [3, 2, 1]);
    expect(data.agendaItems.map((item) => item.schedule.id), [3, 2, 1]);
  });

  test(
    'waits for authentication, reuses requests, and clears on logout',
    () async {
      final tokens = <String>[];
      final controller = CalendarController(
        tripLoader: (token) async {
          tokens.add(token);
          return [];
        },
      );
      addTearDown(controller.dispose);
      controller.updateSession(isInitialized: false, accessToken: 'first');
      expect(controller.calendarFuture, isNull);
      controller.updateSession(isInitialized: true, accessToken: 'first');
      final first = controller.calendarFuture;
      await first;
      controller.updateSession(isInitialized: true, accessToken: 'first');
      expect(controller.calendarFuture, same(first));
      controller.updateSession(isInitialized: true, accessToken: 'second');
      await controller.calendarFuture;
      controller.updateSession(isInitialized: true, accessToken: null);
      expect(controller.calendarFuture, isNull);
      controller.reload();
      expect(tokens, ['first', 'second']);
    },
  );

  test(
    'retries failed loads and reloads after saving the complete draft',
    () async {
      var loads = 0;
      CalendarScheduleDraft? saved;
      final controller = CalendarController(
        tripLoader: (_) async {
          if (++loads == 1) throw StateError('request failed');
          return [];
        },
        scheduleCreator: (token, draft) async {
          expect(token, 'test');
          saved = draft;
        },
      );
      addTearDown(controller.dispose);
      controller.updateSession(isInitialized: true, accessToken: 'test');
      await expectLater(controller.calendarFuture, throwsStateError);
      controller.reload();
      await controller.calendarFuture;
      final draft = _draft();
      await controller.addSchedule(draft, accessToken: 'test');
      await controller.calendarFuture;
      expect(saved, same(draft));
      expect(loads, 3);
    },
  );

  test('failed saves do not replace the current calendar request', () async {
    final controller = CalendarController(
      tripLoader: (_) async => [],
      scheduleCreator: (_, _) async => throw StateError('save failed'),
    );
    addTearDown(controller.dispose);
    controller.updateSession(isInitialized: true, accessToken: 'test');
    final request = controller.calendarFuture;
    await request;
    await expectLater(
      controller.addSchedule(_draft(), accessToken: 'test'),
      throwsStateError,
    );
    expect(controller.calendarFuture, same(request));
  });

  test('a save for an old account does not refresh the new account', () async {
    final pending = Completer<void>();
    final tokens = <String>[];
    final controller = CalendarController(
      tripLoader: (token) async {
        tokens.add(token);
        return [];
      },
      scheduleCreator: (_, _) => pending.future,
    );
    addTearDown(controller.dispose);
    controller.updateSession(isInitialized: true, accessToken: 'first');
    await controller.calendarFuture;
    final saving = controller.addSchedule(_draft(), accessToken: 'first');
    controller.updateSession(isInitialized: true, accessToken: 'second');
    final second = controller.calendarFuture;
    await second;
    pending.complete();
    await saving;
    expect(controller.calendarFuture, same(second));
    expect(tokens, ['first', 'second']);
  });

  test('a save finishing after disposal does not reload or notify', () async {
    final pending = Completer<void>();
    var loads = 0;
    var notifications = 0;
    final controller = CalendarController(
      tripLoader: (_) async {
        loads++;
        return [];
      },
      scheduleCreator: (_, _) => pending.future,
    );
    controller.addListener(() => notifications++);
    controller.updateSession(isInitialized: true, accessToken: 'test');
    await controller.calendarFuture;
    final saving = controller.addSchedule(_draft(), accessToken: 'test');
    controller.dispose();
    pending.complete();
    await saving;
    controller.reload();
    expect(loads, 1);
    expect(notifications, 0);
  });

  test(
    'detail groups the timeline and caches members until the token changes',
    () async {
      final selected = _schedule(1, 7, 31, '12:00:00');
      final tokens = <String>[];
      final controller = TripCalendarDetailController(
        schedules: [selected, _schedule(2, 7, 30, '09:00:00')],
        selectedSchedule: selected,
        memberLoader: (token, tripId) async {
          expect(tripId, 7);
          tokens.add(token);
          return [];
        },
      );
      expect(controller.timelineSections.length, 2);
      expect(controller.timelineSections.first.items.single.schedule.id, 2);
      expect(controller.timeRange, '09:00 - 12:00');
      controller.updateSession('first');
      final first = controller.membersFuture;
      await first;
      controller.updateSession('first');
      expect(controller.membersFuture, same(first));
      controller.updateSession('second');
      await controller.membersFuture;
      controller.updateSession(null);
      expect(controller.membersFuture, isNull);
      expect(tokens, ['first', 'second']);
    },
  );
}
