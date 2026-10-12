/// ============================================================
///  ADMIN — ROUTES DE L'APPLICATION
/// ============================================================
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  // Branches du shell (onglets)
  static const String home = '/home';
  static const String commands = '/commands';
  static const String deliverers = '/deliverers';
  static const String stats = '/stats';
  static const String profile = '/profile';

  // Routes poussées par-dessus le shell
  static const String commandDetail = '/command/:id';
  static const String delivererDetail = '/deliverer/:id';

  static String commandDetailPath(String id) => '/command/$id';
  static String delivererDetailPath(String id) => '/deliverer/$id';
}
