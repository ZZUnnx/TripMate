import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/controllers/settlement/settlement_detail_controller.dart';
import 'package:frontend/controllers/settlement/settlement_list_controller.dart';
import 'package:frontend/models/settlement.dart';

import '../fixtures/settlement_fixture.dart';

void main() {
  test('list waits for authentication and clears on logout', () async {
    final tokens = <String>[];
    final controller = SettlementListController(
      tripLoader: (token) async {
        tokens.add(token);
        return [settlementFixture()];
      },
    );
    addTearDown(controller.dispose);
    controller.updateSession(isInitialized: false, accessToken: 'first');
    expect(controller.tripsFuture, isNull);
    controller.updateSession(isInitialized: true, accessToken: 'first');
    final first = controller.tripsFuture;
    await first;
    controller.updateSession(isInitialized: true, accessToken: 'first');
    expect(controller.tripsFuture, same(first));
    controller.updateSession(isInitialized: true, accessToken: 'second');
    await controller.tripsFuture;
    controller.updateSession(isInitialized: true, accessToken: null);
    expect(controller.tripsFuture, isNull);
    expect(tokens, ['first', 'second']);
  });

  test('detail refreshes after CRUD and completion changes', () async {
    var loads = 0;
    final calls = <String>[];
    final controller = SettlementDetailController(
      tripId: 1,
      accessToken: 'token',
      detailLoader: () async {
        loads++;
        return settlementFixture();
      },
      expenseSaver: (draft, id) async {
        calls.add(id == null ? 'create' : 'edit:$id');
      },
      expenseDeleter: (id) async {
        calls.add('delete:$id');
      },
      completionSaver: (completed) async {
        calls.add('complete:$completed');
      },
    );
    addTearDown(controller.dispose);
    await controller.load();
    final draft = ExpenseDraft(
      title: 'cost',
      amount: 100,
      payerId: 1,
      date: DateTime(2026, 10, 31),
      participantIds: const [1, 2],
    );
    expect(await controller.saveExpense(draft), isTrue);
    await controller.saveExpense(draft, expenseId: 9);
    await controller.deleteExpense(9);
    await controller.setCompleted(true);
    await controller.setCompleted(false);
    expect(calls, [
      'create',
      'edit:9',
      'delete:9',
      'complete:true',
      'complete:false',
    ]);
    expect(loads, 6);
    expect(controller.isBusy, isFalse);
  });

  test(
    'failed mutation retains data and clears busy state for retry',
    () async {
      var fail = true;
      final fixture = settlementFixture();
      final controller = SettlementDetailController(
        tripId: 1,
        accessToken: 'token',
        detailLoader: () async => fixture,
        expenseDeleter: (_) async {
          if (fail) throw StateError('denied');
        },
      );
      addTearDown(controller.dispose);
      await controller.load();
      await expectLater(controller.deleteExpense(9), throwsStateError);
      expect(controller.data, same(fixture));
      expect(controller.isBusy, isFalse);
      fail = false;
      expect(await controller.deleteExpense(9), isTrue);
    },
  );

  test('only the most recent load updates the detail', () async {
    final first = Completer<SettlementData>();
    final second = Completer<SettlementData>();
    var loads = 0;
    final controller = SettlementDetailController(
      tripId: 1,
      accessToken: 'token',
      detailLoader: () => ++loads == 1 ? first.future : second.future,
    );
    addTearDown(controller.dispose);
    final a = controller.load();
    final b = controller.load();
    second.complete(settlementFixture(amount: 200));
    await b;
    first.complete(settlementFixture(amount: 100));
    await a;
    expect(controller.data!.totalAmount, 200);
  });

  test(
    'prevents duplicate mutations and does not refresh after disposal',
    () async {
      final pending = Completer<void>();
      var loads = 0;
      var saves = 0;
      final controller = SettlementDetailController(
        tripId: 1,
        accessToken: 'token',
        detailLoader: () async {
          loads++;
          return settlementFixture();
        },
        completionSaver: (_) {
          saves++;
          return pending.future;
        },
      );
      await controller.load();
      final result = controller.setCompleted(true);
      expect(await controller.setCompleted(true), isFalse);
      controller.dispose();
      pending.complete();
      await result;
      expect(saves, 1);
      expect(loads, 1);
    },
  );
}
