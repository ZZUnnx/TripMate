import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('home screen shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsWidgets);
    expect(find.byIcon(Icons.calendar_today_outlined), findsWidgets);
    expect(find.byIcon(Icons.payments_outlined), findsWidgets);
  });
}
