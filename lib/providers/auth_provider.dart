import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/firestore_repository.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────

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

// ─── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthIdle();

  FirestoreRepository get _repo => FirestoreRepository.instance;

  /// Attempts login with the given credentials.
  Future<void> login(String username, String password) async {
    state = const AuthLoading();
    try {
      final session = await _repo.checkCredentials(username, password);
      state = AuthAuthenticated(session);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('AppException: ', '').replaceAll('Exception: ', ''));
    }
  }

  /// Clears session and returns to idle.
  void logout() {
    state = const AuthIdle();
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
