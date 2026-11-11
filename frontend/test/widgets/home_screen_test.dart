import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/home/home_controller.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/models/trip_schedule.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/providers/auth_provider.dart';

import '../fixtures/settlement_fixture.dart';

class HomeTestAuth extends SettlementTestAuth {
  bool loggedIn = true;
  @override
  bool get isLoggedIn => loggedIn;
  @override
  String? get nickname => '실제사용자';
  @override
  String? get accessToken => loggedIn ? 'token' : null;
  void signOut() {
    loggedIn = false;
    notifyListeners();
  }
}

void main() {
  testWidgets(
    'shows API data, filters monthly schedules, and refreshes on activation',
    (tester) async {
      var amount = 12345;
      var calls = 0;
      final controller = HomeController(
        clock: () => DateTime(2026, 11, 11, 12),
        tripLoader: (_) async {
          calls++;
          return [
            Trip(id: 1, title: '실제 제주 여행', startDate: DateTime(2026, 11, 12)),
          ];
        },
        scheduleLoader: (_, _) async => [
          TripSchedule(
            id: 1,
            tripId: 1,
            tripTitle: '실제 제주 여행',
            title: '공항에서 모이기',
            scheduledDate: DateTime(2026, 11, 12),
            scheduledTime: '09:00:00',
            category: '공유 여행',
            sortOrder: 0,
          ),
          TripSchedule(
            id: 2,
            tripId: 1,
            tripTitle: '실제 제주 여행',
            title: '다음 달 일정',
            scheduledDate: DateTime(2026, 12, 12),
            category: '공유 여행',
            sortOrder: 0,
          ),
        ],
        settlementLoader: (_) async => [settlementFixture(amount: amount)],
      );
      final auth = HomeTestAuth();
      var active = true;
      Widget app() => ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: MaterialApp(
          home: HomeScreen(controller: controller, isActive: active),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('실제사용자'), findsOneWidget);
      expect(find.text('참여 여행 1개 · 동행 1명'), findsOneWidget);
      expect(find.text('D-1'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('₩12,345'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('₩12,345'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('공항에서 모이기'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('다음 달 일정'), findsNothing);
      expect(find.text('봄바람 따라, 제주'), findsNothing);
      active = false;
      await tester.pumpWidget(app());
      amount = 20000;
      active = true;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(calls, 2);
      await tester.scrollUntilVisible(
        find.text('₩20,000'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('₩20,000'), findsOneWidget);
      auth.signOut();
      await tester.pumpAndSettle();
      expect(find.text('₩20,000'), findsNothing);
      expect(find.text('로그인하고 내 여행 보기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty state contains no sample trips or amounts', (
    tester,
  ) async {
    final controller = HomeController(
      tripLoader: (_) async => [],
      scheduleLoader: (_, _) async => [],
      settlementLoader: (_) async => [],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: HomeTestAuth(),
        child: MaterialApp(home: HomeScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('참여 여행 0개 · 동행 0명'), findsOneWidget);
    expect(find.text('다가오는 여행이 없어요. 새 여행을 만들어 보세요.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('이번 달 등록된 일정이 없습니다.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('오사카 겨울 여행'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed trip load provides a working retry', (tester) async {
    var fail = true;
    final controller = HomeController(
      tripLoader: (_) async {
        if (fail) throw StateError('offline');
        return [];
      },
      scheduleLoader: (_, _) async => [],
      settlementLoader: (_) async => [],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: HomeTestAuth(),
        child: MaterialApp(home: HomeScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('홈 정보를 불러오지 못했어요.'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('참여 여행 0개 · 동행 0명'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
