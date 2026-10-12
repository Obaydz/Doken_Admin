import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_user_model.dart';
import '../repositories/auth_repository.dart';
import 'mock_data.dart';

/// ============================================================
///  ADMIN — AUTHENTIFICATION FICTIVE (MOCK)
///  Compte de démonstration : admin@doken.com / Admin1234
///  Compte de test d'échec  : fail@doken.com / n'importe quel mdp
/// ============================================================
class MockAuthRepository implements AuthRepository {
  final Duration latency;

  MockAuthRepository({this.latency = const Duration(milliseconds: 800)});

  @override
  Future<AdminUserModel> login(String email, String password) async {
    await Future.delayed(latency);

    final normalizedEmail = email.trim().toLowerCase();

    // Cas de test d'échec
    if (normalizedEmail == 'fail@doken.com') {
      throw Exception('Compte temporairement bloqué ou identifiants erronés.');
    }

    // Compte de démonstration officiel
    if (normalizedEmail == 'admin@doken.com' && password == 'Admin1234') {
      return MockData.defaultAdmin;
    }

    // Souplesse de test : tout e-mail valide + mot de passe d'au moins 6 caractères
    if (password.length >= 6 && !password.contains('wrong')) {
      final namePart = normalizedEmail.split('@').first;
      final capitalized = namePart.isEmpty
          ? 'Admin doken'
          : namePart[0].toUpperCase() + namePart.substring(1);
      return AdminUserModel(
        id: 'ADM-TMP',
        name: capitalized,
        email: normalizedEmail,
        role: 'Administrateur',
        avatar: '',
      );
    }

    throw Exception(
        'Identifiants incorrects. Veuillez vérifier votre adresse e-mail et mot de passe.');
  }
}

/// Provider pour injecter le repository d'authentification
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});
