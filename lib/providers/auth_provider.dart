import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUserEmail;
  String? _currentUserName;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _currentUserEmail = prefs.getString('userEmail');
    _currentUserName = prefs.getString('userName');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final storedPassword = prefs.getString('password_$normalizedEmail');

    if (storedPassword != null && storedPassword == password) {
      _isAuthenticated = true;
      _currentUserEmail = normalizedEmail;
      _currentUserName = prefs.getString('name_$normalizedEmail');

      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userEmail', normalizedEmail);
      if (_currentUserName != null) {
        await prefs.setString('userName', _currentUserName!);
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();
    final userExists = prefs.getString('password_$normalizedEmail') != null;

    if (userExists) {
      return false; // User already exists
    }

    await prefs.setString('name_$normalizedEmail', name.trim());
    await prefs.setString('password_$normalizedEmail', password);

    return true; // Successfully registered
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('userEmail');
    await prefs.remove('userName');

    _isAuthenticated = false;
    _currentUserEmail = null;
    _currentUserName = null;

    notifyListeners();
  }
}
