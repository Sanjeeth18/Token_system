import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/token_model.dart';
import '../repositories/firestore_repository.dart';

// ─── Token Counts (Manager Dashboard) ────────────────────────────────────────

class TokenCountsNotifier extends Notifier<AsyncValue<TokenCounts>> {
  @override
  AsyncValue<TokenCounts> build() => const AsyncValue.loading();

  FirestoreRepository get _repo => FirestoreRepository.instance;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final counts = await _repo.getTokenCounts();
      state = AsyncValue.data(counts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setCount(String type, int count) async {
    try {
      await _repo.setTokenCount(type, count);
      await refresh();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final tokenCountsProvider =
    NotifierProvider<TokenCountsNotifier, AsyncValue<TokenCounts>>(
  TokenCountsNotifier.new,
);

// ─── Student Tokens (Student Home / Wallet) ───────────────────────────────────

class StudentTokensNotifier extends FamilyNotifier<AsyncValue<StudentTokens>, String> {
  @override
  AsyncValue<StudentTokens> build(String rollNumber) {
    _load(rollNumber);
    return const AsyncValue.loading();
  }

  FirestoreRepository get _repo => FirestoreRepository.instance;

  Future<void> _load(String roll) async {
    try {
      final tokens = await _repo.getStudentTokens(roll);
      state = AsyncValue.data(tokens);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh(String roll) => _load(roll);

  void updateTokens(StudentTokens tokens) {
    state = AsyncValue.data(tokens);
  }
}

final studentTokensProvider = NotifierProviderFamily<StudentTokensNotifier,
    AsyncValue<StudentTokens>, String>(
  StudentTokensNotifier.new,
);

// ─── Token Selection (Purchase Flow) ─────────────────────────────────────────

class TokenSelectionNotifier extends Notifier<TokenSelection> {
  @override
  TokenSelection build() => const TokenSelection();

  void toggleNonVeg() {
    state = state.copyWith(wantsNonVeg: !state.wantsNonVeg);
  }

  void toggleVeg() {
    state = state.copyWith(wantsVeg: !state.wantsVeg);
  }

  void setEggCount(int count) {
    state = state.copyWith(eggCount: count.clamp(0, 99));
  }

  void incrementEggs() {
    state = state.copyWith(eggCount: state.eggCount + 15);
  }

  void decrementEggs() {
    final newCount = (state.eggCount - 15).clamp(0, 999);
    state = state.copyWith(eggCount: newCount);
  }

  void reset() {
    state = const TokenSelection();
  }
}

final tokenSelectionProvider =
    NotifierProvider<TokenSelectionNotifier, TokenSelection>(
  TokenSelectionNotifier.new,
);
