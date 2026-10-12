import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/mock/mock_auth_repository.dart';

/// ============================================================
///  ADMIN — ÉTAT DE SESSION (ADMIN CONNECTÉ OU NON)
/// ============================================================
class SessionState {
  final AdminUserModel? user;
  final bool isLoading;
  final String? authError;

  const SessionState({
    this.user,
    this.isLoading = false,
    this.authError,
  });

  bool get isAuthenticated => user != null;

  SessionState copyWith({
    AdminUserModel? Function()? user,
    bool? isLoading,
    String? Function()? authError,
  }) {
    return SessionState(
      user: user != null ? user() : this.user,
      isLoading: isLoading ?? this.isLoading,
      authError: authError != null ? authError() : this.authError,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref _ref;

  SessionNotifier(this._ref) : super(const SessionState());

  /// Connexion administrateur via le repository injecté
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, authError: () => null);

    try {
      final repo = _ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);

      state = state.copyWith(
        user: () => user,
        isLoading: false,
        authError: () => null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        authError: () =>
            e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Déconnexion : bascule en écran de connexion
  void logout() {
    state = const SessionState();
  }

  /// Efface l'erreur affichée
  void clearAuthError() {
    state = state.copyWith(authError: () => null);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref);
});
