/// ============================================================
///  ADMIN — MODÈLE UTILISATEUR ADMINISTRATEUR
/// ============================================================
class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String role; // "Directeur des Opérations", "Dispatcheur"...
  final String avatar;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
  });
}
