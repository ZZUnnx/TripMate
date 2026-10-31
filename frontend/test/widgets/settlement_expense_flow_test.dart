import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/settlement/settlement_detail_controller.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/settlement/settlement_screen.dart';
import 'package:frontend/widgets/settlement/expense_editor_sheet.dart';
import 'package:frontend/widgets/settlement/settlement_result_sheet.dart';

import '../fixtures/settlement_fixture.dart';

void main() {
  testWidgets('completion is saved only after explicit confirmation', (
    tester,
  ) async {
    bool? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SettlementResultSheet(
                  data: settlementFixture(),
                  onComplete: (completed) async {
                    saved = completed;
                    return true;
                  },
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('서준 → 민지'), findsOneWidget);
    await tester.ensureVisible(find.text('정산 완료로 표시'));
    await tester.tap(find.text('정산 완료로 표시'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
    await tester.tap(find.text('정산 완료로 표시'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(saved, isTrue);
    expect(find.byType(SettlementResultSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('empty trip accepts an expense and shows updated totals', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var data = settlementFixture(empty: true);
    final controller = SettlementDetailController(
      tripId: 1,
      accessToken: 'token',
      detailLoader: () async => data,
      expenseSaver: (draft, id) async {
        expect(draft.title, '저녁 식사');
        expect(draft.amount, 20000);
        expect(draft.participantIds, [1, 2]);
        data = settlementFixture(amount: draft.amount);
      },
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => SettlementTestAuth(),
        child: MaterialApp(
          home: SettlementScreen(
            tripId: 1,
            controllerFactory: (_, _) => controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('지출 등록'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpenseEditorSheet), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '저녁 식사');
    await tester.enterText(find.byType(TextFormField).at(1), '20000');
    await tester.ensureVisible(find.text('저장'));
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpenseEditorSheet), findsNothing);
    expect(find.text('총지출 · 1건'), findsOneWidget);
    expect(find.text('₩20,000'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'expense editor rejects invalid amounts and an empty participant set',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseEditorSheet(
              members: settlementFixture().members,
              currentUserId: 1,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'test');
      await tester.enterText(find.byType(TextFormField).at(1), '-1');
      await tester.ensureVisible(find.text('저장'));
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.textContaining('정수를 입력해주세요'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(1), '100');
      await tester.tap(find.widgetWithText(FilterChip, '민지'));
      await tester.tap(find.widgetWithText(FilterChip, '서준'));
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.text('분담 대상을 한 명 이상 선택해주세요.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
