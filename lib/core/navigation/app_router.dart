import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feature/auth/login_screen.dart';
import '../../feature/commands/command_detail_screen.dart';
import '../../feature/commands/commands_screen.dart';
import '../../feature/dashboard/dashboard_screen.dart';
import '../../feature/dashboard/dashboard_shell.dart';
import '../../feature/deliverers/deliverer_detail_screen.dart';
import '../../feature/deliverers/deliverers_screen.dart';
import '../../feature/splash/splash_screen.dart';
import '../../feature/stats/stats_screen.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNav');

/// ============================================================
///  ADMIN — CONFIGURATION DU ROUTEUR GO_ROUTER
/// ============================================================
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    // --- Écran de démarrage (Splash) ---
    GoRoute(
      path: AppRoutes.splash,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),

    // --- Connexion admin ---
    GoRoute(
      path: AppRoutes.login,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),

    // --- Coquille avec navigation inférieure persistante (4 onglets) ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return DashboardShell(navigationShell: navigationShell);
      },
      branches: [
        // Branche 0 : Tableau de bord
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Branche 1 : Commandes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.commands,
              builder: (context, state) => const CommandsScreen(),
            ),
          ],
        ),

        // Branche 2 : Livreurs
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.deliverers,
              builder: (context, state) => const DeliverersScreen(),
            ),
          ],
        ),

        // Branche 3 : Statistiques
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.stats,
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),

    // --- Détail d'une commande (au-dessus du shell) ---
    GoRoute(
      path: AppRoutes.commandDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CommandDetailScreen(commandId: id);
      },
    ),

    // --- Détail d'un livreur (au-dessus du shell) ---
    GoRoute(
      path: AppRoutes.delivererDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DelivererDetailScreen(delivererId: id);
      },
    ),
  ],
);
