import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/navigation/routes.dart';
import '../../core/session/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../providers/operations_provider.dart';

/// ============================================================
///  ADMIN — COQUILLE DE NAVIGATION PERSISTANTE (4 ONGLETS)
///  Bandeau d'alertes temps réel au-dessus du contenu.
/// ============================================================
class DashboardShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardShell({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsListProvider);
    final user = ref.watch(sessionProvider).user;

    return Scaffold(
      body: Column(
        children: [
          // ── Barre supérieure (marque + utilisateur + déconnexion) ──
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space24),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  AppConfig.appName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (user != null) ...[
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.avatar.isNotEmpty
                        ? NetworkImage(user.avatar)
                        : null,
                    child: user.avatar.isEmpty
                        ? Text(
                            user.name.isNotEmpty ? user.name[0] : 'A',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  if (MediaQuery.of(context).size.width > 500)
                    Text(
                      user.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary),
                    ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      ref.read(sessionProvider.notifier).logout();
                      context.go(AppRoutes.login);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout_rounded,
                              size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 5),
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Bandeau d'alertes temps réel ──
          if (alerts.isNotEmpty) _AlertBanner(latestMessage: alerts.first),

          // ── Contenu de l'onglet actif ──
          Expanded(child: navigationShell),
        ],
      ),

      // ── Barre de navigation inférieure ──
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Tableau',
            tooltip: 'Onglet Tableau de bord',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            label: 'Commandes',
            tooltip: 'Onglet Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bike_outlined),
            selectedIcon:
                Icon(Icons.directions_bike_rounded, color: AppColors.primary),
            label: 'Livreurs',
            tooltip: 'Onglet Livreurs',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon:
                Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            label: 'Statistiques',
            tooltip: 'Onglet Statistiques',
          ),
        ],
      ),
    );
  }
}

// ── Bandeau d'alerte ─────────────────────────────────────────────────────────

class _AlertBanner extends ConsumerWidget {
  final String latestMessage;
  const _AlertBanner({required this.latestMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(latestMessage),
      direction: DismissDirection.horizontal,
      onDismissed: (_) =>
          ref.read(operationsProvider.notifier).clearAlerts(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.space24, vertical: 10),
        color: AppColors.primaryLight,
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                latestMessage,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  ref.read(operationsProvider.notifier).clearAlerts(),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

