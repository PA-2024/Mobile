import 'package:flutter_riverpod/flutter_riverpod.dart';

final authenticationProvider = StateNotifierProvider<AuthenticationNotifier, String?>((ref) {
  return AuthenticationNotifier();
});

class AuthenticationNotifier extends StateNotifier<String?> {
  AuthenticationNotifier() : super(null);

  void setToken(String token) {
    state = token;
  }

  void clearToken() {
    state = null;
  }
}
