import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/home/home_controller.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/models/trip_schedule.dart';

import '../fixtures/settlement_fixture.dart';

TripSchedule schedule(int id, DateTime date, {String? time}) => TripSchedule(
  id: id,
  tripId: 1,
  tripTitle: '실제 여행',
  title: '일정 $id',
  scheduledDate: date,
  scheduledTime: time,
  category: '공유 여행',
  sortOrder: 0,
);

void main() {
  final now = DateTime(2026, 11, 11, 12);
  final trips = [
    Trip(
      id: 1,
      title: '진행 중',
      startDate: DateTime(2026, 11, 10),
      endDate: DateTime(2026, 11, 12),
    ),
    Trip(id: 2, title: '예정', startDate: DateTime(2026, 12, 1)),
    const Trip(id: 3, title: '미정'),
    Trip(
      id: 4,
      title: '지난 여행',
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 5),
    ),
  ];

  test(
    'loads trips once and derives real home counts and date ranges',
    () async {
      final requested = <int>[];
      var tripCalls = 0;
      final controller = HomeController(
        clock: () => now,
        tripLoader: (token) async {
          expect(token, 'token');
          tripCalls++;
          return trips;
        },
        scheduleLoader: (_, id) async {
          requested.add(id);
          return id != 1
              ? []
              : [
                  schedule(1, DateTime(2026, 11, 11), time: '11:00:00'),
                  schedule(2, DateTime(2026, 11, 11), time: '13:00:00'),
                  schedule(3, DateTime(2026, 12, 1)),
                  schedule(4, DateTime(2025, 11, 12)),
                ];
        },
        settlementLoader: (_) async => [
          settlementFixture(tripId: 1),
          settlementFixture(tripId: 2, amount: 20000, completed: true),
          settlementFixture(tripId: 3, empty: true),
          settlementFixture(tripId: 999),
        ],
      );
      addTearDown(controller.dispose);
      controller.updateSession(
        isInitialized: true,
        accessToken: 'token',
        userId: 1,
      );
      final data = await controller.homeFuture!;
      expect(requested, [1, 2, 3, 4]);
      expect(data.activeTrip!.id, 1);
      expect(data.upcomingTrips.map((t) => t.id), [1, 2, 3]);
      expect(data.monthlySchedules!.map((s) => s.id), [1, 2]);
      expect(data.nextSchedule!.id, 2);
      expect(data.companionCount, 1);
      expect(data.totalAmount, 30000);
      expect(data.expenseCount, 2);
      expect(data.needsAttention!.map((s) => s.tripId), [1]);
      controller.updateSession(
        isInitialized: true,
        accessToken: 'token',
        userId: 1,
      );
      expect(tripCalls, 1);
    },
  );

  test(
    'section failures preserve trips and never become zero totals',
    () async {
      final controller = HomeController(
        tripLoader: (_) async => trips,
        scheduleLoader: (_, _) async => throw StateError('offline'),
        settlementLoader: (_) async => throw StateError('offline'),
      );
      addTearDown(controller.dispose);
      controller.updateSession(
        isInitialized: true,
        accessToken: 'token',
        userId: 1,
      );
      final data = await controller.homeFuture!;
      expect(data.trips.length, 4);
      expect(data.schedules, isNull);
      expect(data.totalAmount, isNull);
      expect(data.companionCount, isNull);
      expect(data.warnings.length, 2);
    },
  );

  test('empty account and reload reflect latest data', () async {
    var calls = 0;
    final controller = HomeController(
      tripLoader: (_) async {
        calls++;
        return calls == 1 ? [] : trips;
      },
      scheduleLoader: (_, _) async => [],
      settlementLoader: (_) async => [],
    );
    addTearDown(controller.dispose);
    controller.updateSession(
      isInitialized: true,
      accessToken: 'token',
      userId: 1,
    );
    final empty = await controller.homeFuture!;
    expect(empty.activeTrip, isNull);
    expect(empty.totalAmount, 0);
    expect(empty.nextSchedule, isNull);
    await controller.reload();
    expect((await controller.homeFuture!).trips.length, 4);
  });

  test('logout and a new session cannot display an old request', () async {
    final pending = Completer<List<Trip>>();
    final controller = HomeController(
      tripLoader: (token) => token == 'old' ? pending.future : Future.value([]),
      scheduleLoader: (_, _) async => [],
      settlementLoader: (_) async => [],
    );
    addTearDown(controller.dispose);
    controller.updateSession(
      isInitialized: false,
      accessToken: 'old',
      userId: 1,
    );
    expect(controller.homeFuture, isNull);
    controller.updateSession(
      isInitialized: true,
      accessToken: 'old',
      userId: 1,
    );
    final old = controller.homeFuture;
    controller.updateSession(
      isInitialized: true,
      accessToken: null,
      userId: null,
    );
    expect(controller.homeFuture, isNull);
    controller.updateSession(
      isInitialized: true,
      accessToken: 'new',
      userId: 2,
    );
    pending.complete(trips);
    await old;
    expect((await controller.homeFuture!).trips, isEmpty);
  });
}
