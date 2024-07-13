import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authenticationProvider = StateNotifierProvider<AuthenticationNotifier, String?>((ref) {
  return AuthenticationNotifier();
});

class AuthenticationNotifier extends StateNotifier<String?> {
  AuthenticationNotifier() : super(null) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      state = token;
    }
  }

  Future<void> setToken(String token) async {
    state = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}

