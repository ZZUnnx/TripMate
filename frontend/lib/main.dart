import 'package:flutter/material.dart';

import 'screens/app_shell.dart';

export 'screens/chat/chat_screen.dart';
export 'screens/calendar/calendar_screen.dart';
export 'screens/home/home_screen.dart';
export 'screens/settlement/settlement_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF635BFF)),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFBFBFD),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
