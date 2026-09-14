import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  int? _userId;
  String? _email;
  String? _nickname;
  String? _accessToken;

  bool _isInitialized = false;

  int? get userId => _userId;
  String? get email => _email;
  String? get nickname => _nickname;
  String? get accessToken => _accessToken;

  bool get isLoggedIn => _accessToken != null;
  bool get isInitialized => _isInitialized;

  Future<void> loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();

    _userId = prefs.getInt('userId');
    _email = prefs.getString('email');
    _nickname = prefs.getString('nickname');
    _accessToken = prefs.getString('accessToken');

    _isInitialized = true;

    notifyListeners();
  }

  Future<void> login({
    required int userId,
    required String email,
    required String nickname,
    required String accessToken,
  }) async {
    _userId = userId;
    _email = email;
    _nickname = nickname;
    _accessToken = accessToken;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('userId', userId);
    await prefs.setString('email', email);
    await prefs.setString('nickname', nickname);
    await prefs.setString('accessToken', accessToken);

    notifyListeners();
  }

  Future<void> logout() async {
    _userId = null;
    _email = null;
    _nickname = null;
    _accessToken = null;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('nickname');
    await prefs.remove('accessToken');

    notifyListeners();
  }
}