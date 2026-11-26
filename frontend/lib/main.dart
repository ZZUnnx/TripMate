import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';

import 'screens/app_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'widgets/common/app_viewport.dart';

export 'screens/chat/chat_screen.dart';
export 'screens/calendar/calendar_screen.dart';
export 'screens/home/home_screen.dart';
export 'screens/settlement/settlement_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadLoginState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripMate',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppViewport(child: child!),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF635BFF)),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFBFBFD),
        useMaterial3: true,
      ),

      home: const AppShell(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
