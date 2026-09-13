import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  int? _userId;
  String? _email;
  String? _nickname;

  int? get userId => _userId;
  String? get email => _email;
  String? get nickname => _nickname;

  bool get isLoggedIn => _userId != null;

  void login({
    required int userId,
    required String email,
    required String nickname,
  }) {
    _userId = userId;
    _email = email;
    _nickname = nickname;

    notifyListeners();
  }

  void logout() {
    _userId = null;
    _email = null;
    _nickname = null;

    notifyListeners();
  }
}