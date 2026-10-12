import '../models/admin_user_model.dart';

/// ============================================================
///  ADMIN — INTERFACE DU REPOSITORY D'AUTHENTIFICATION
/// ============================================================
abstract class AuthRepository {
  /// Connexion administrateur
  Future<AdminUserModel> login(String email, String password);
}
