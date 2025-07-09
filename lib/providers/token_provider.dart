import 'package:flutter_riverpod/flutter_riverpod.dart';

class JwtNotifier extends StateNotifier<String?> {
  JwtNotifier() : super(null);

  void setToken(String token) {
    state = token;
  }

  void clearToken() {
    state = null;
  }
}

final jwtProvider = StateNotifierProvider<JwtNotifier, String?>((ref) => JwtNotifier());
