import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/firestore_repository.dart';

/// Represents the current authentication state.
sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserSession session;
  const AuthAuthenticated(this.session);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Notifier for authentication logic and session management.
class AuthNotifier extends Notifier<AuthState> {
  static const String _keyUserSession = 'user_session_json';

  @override
  AuthState build() {
    _restoreSession();
    return const AuthIdle();
  }

  FirestoreRepository get _repo => FirestoreRepository.instance;

  /// Restores saved session from SharedPreferences on app launch.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_keyUserSession);
      if (rawJson != null && rawJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(rawJson);
        final session = UserSession.fromJson(data);
        state = AuthAuthenticated(session);
      }
    } catch (_) {}
  }

  /// Saves session to SharedPreferences.
  Future<void> _saveSession(UserSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserSession, jsonEncode(session.toJson()));
    } catch (_) {}
  }

  /// Clears session from SharedPreferences.
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserSession);
    } catch (_) {}
  }

  /// Attempts login with the given credentials.
  Future<void> login(String username, String password) async {
    state = const AuthLoading();
    try {
      final session = await _repo.checkCredentials(username, password);
      await _saveSession(session);
      state = AuthAuthenticated(session);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('AppException: ', '').replaceAll('Exception: ', ''));
    }
  }

  /// Clears session and returns to idle.
  Future<void> logout() async {
    final current = currentSession;
    try {
      await _repo.signOut(userId: current?.id, role: current?.role);
    } catch (_) {}
    await _clearSession();
    state = const AuthIdle();
  }

  /// Updates current session profile fields in Riverpod state & SharedPreferences.
  Future<void> updateProfileSession({
    String? name,
    String? department,
    String? photoUrl,
  }) async {
    final current = currentSession;
    if (current != null) {
      final updated = current.copyWith(
        name: name ?? current.name,
        department: department ?? current.department,
        photoUrl: photoUrl ?? current.photoUrl,
      );
      await _saveSession(updated);
      state = AuthAuthenticated(updated);
    }
  }

  /// Convenience getter for current session (null if not authenticated).
  UserSession? get currentSession {
    final s = state;
    return s is AuthAuthenticated ? s.session : null;
  }
}

/// The primary auth provider.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Convenience provider — returns current session or null.
final currentSessionProvider = Provider<UserSession?>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthAuthenticated ? authState.session : null;
});
