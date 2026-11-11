import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/main.dart';
import 'package:frontend/providers/auth_provider.dart';

class _SignedOutAuth extends AuthProvider {
  @override
  bool get isInitialized => true;
}

void main() {
  testWidgets('home screen shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => _SignedOutAuth(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('로그인하고 내 여행 보기'), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsWidgets);
    expect(find.byIcon(Icons.calendar_month_outlined), findsWidgets);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsWidgets);
  });
}
