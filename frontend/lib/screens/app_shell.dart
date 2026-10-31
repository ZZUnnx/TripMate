import 'package:flutter/material.dart';

import 'calendar/calendar_screen.dart';
import 'chat/chat_screen.dart';
import 'home/home_screen.dart';
import 'settlement/settlement_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (index > 3 || index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        HomeScreen(currentIndex: 0, onNavigationSelected: _selectTab),
        ChatScreen(currentIndex: 1, onNavigationSelected: _selectTab),
        CalendarScreen(
          currentIndex: 2,
          onNavigationSelected: _selectTab,
          isActive: _currentIndex == 2,
        ),
        SettlementListScreen(
          currentIndex: 3,
          onNavigationSelected: _selectTab,
          isActive: _currentIndex == 3,
        ),
      ],
    );
  }
}
