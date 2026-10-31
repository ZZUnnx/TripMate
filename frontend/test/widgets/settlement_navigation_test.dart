import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controllers/settlement/settlement_list_controller.dart';
import 'package:frontend/controllers/settlement/settlement_detail_controller.dart';
import 'package:frontend/providers/auth_provider.dart';

import '../fixtures/settlement_fixture.dart';

import 'package:frontend/screens/settlement/settlement_list_screen.dart';
import 'package:frontend/screens/settlement/settlement_screen.dart';
import 'package:frontend/widgets/settlement/settlement_top_header.dart';
import 'package:frontend/widgets/settlement/settlement_trip_card.dart';

void main() {
  testWidgets('travel cards open the selected detail and return to the list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    int? selectedTab;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => SettlementTestAuth(),
        child: MaterialApp(
          home: SettlementListScreen(
            controller: SettlementListController(
              tripLoader: (_) async => [
                settlementFixture(),
                settlementFixture(tripId: 2, title: '오사카 겨울 여행', empty: true),
                settlementFixture(tripId: 3, title: '강릉 당일치기', completed: true),
              ],
            ),
            detailControllerFactory: (id, token) => SettlementDetailController(
              tripId: id,
              accessToken: token,
              detailLoader: () async => settlementFixture(
                tripId: id,
                title: id == 2 ? '오사카 겨울 여행' : '제주 봄 여행',
                empty: id == 2,
              ),
            ),
            onNavigationSelected: (index) => selectedTab = index,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettlementTripCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('제주 봄 여행'));
    await tester.pumpAndSettle();
    expect(find.byType(SettlementScreen), findsOneWidget);
    final header = tester.widget<SettlementTopHeader>(
      find.byType(SettlementTopHeader).last,
    );
    expect(header.title, '제주 봄 여행');
    expect(find.text('총지출 · 1건'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('여행 목록으로'));
    await tester.pumpAndSettle();
    expect(find.byType(SettlementScreen), findsNothing);
    await tester.tap(find.text('오사카 겨울 여행'));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 등록된 지출이 없어요'), findsOneWidget);
    expect(find.text('총지출 · 1건'), findsNothing);
    await tester.tap(find.text('홈').last);
    await tester.pumpAndSettle();
    expect(selectedTab, 0);
    expect(find.byType(SettlementScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('travel list fits a narrow mobile screen', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => SettlementTestAuth(),
        child: MaterialApp(
          home: SettlementListScreen(
            controller: SettlementListController(
              tripLoader: (_) async => [
                settlementFixture(),
                settlementFixture(tripId: 2, title: '오사카 겨울 여행', empty: true),
                settlementFixture(tripId: 3, title: '강릉 당일치기', completed: true),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettlementTripCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
