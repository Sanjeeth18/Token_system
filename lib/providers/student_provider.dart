import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/token_model.dart';
import '../repositories/firestore_repository.dart';
import 'token_provider.dart';

// ─── Student Operations Notifier ──────────────────────────────────────────────

class StudentActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const StudentActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  StudentActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return StudentActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class StudentActionNotifier extends Notifier<StudentActionState> {
  @override
  StudentActionState build() => const StudentActionState();

  FirestoreRepository get _repo => FirestoreRepository.instance;

  /// Executes token purchase for the given student roll number.
  Future<bool> purchaseTokens(String rollNumber, TokenSelection selection) async {
    if (!selection.hasSelection) {
      state = state.copyWith(error: 'Please select at least one token to purchase.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final updated = await _repo.purchaseTokens(rollNumber, selection);
      // Update the student tokens in cache
      ref.read(studentTokensProvider(rollNumber).notifier).updateTokens(updated);
      // Reset the purchase selection
      ref.read(tokenSelectionProvider.notifier).reset();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Tokens purchased successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('AppException: ', '').replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = const StudentActionState();
  }
}

final studentActionProvider =
    NotifierProvider<StudentActionNotifier, StudentActionState>(
  StudentActionNotifier.new,
);
