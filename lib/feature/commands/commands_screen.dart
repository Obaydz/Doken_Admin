import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/ui/state_views.dart';
import '../../providers/operations_provider.dart';
import 'command_card.dart';

/// ============================================================
///  ADMIN — ONGLET COMMANDES (pipeline complet + filtres)
/// ============================================================
class CommandsScreen extends ConsumerWidget {
  const CommandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);
    final notifier = ref.read(operationsProvider.notifier);
    final commands = notifier.filteredCommands;

    return Column(
      children: [
        // Recherche + filtres
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(
              AppDimens.space16, AppDimens.space12, AppDimens.space16, AppDimens.space8),
          child: Column(
            children: [
              TextField(
                onChanged: notifier.setSearchQuery,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Rechercher commandes, clients...',
                  prefixIcon:
                      Icon(Icons.search_rounded, size: 18),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 0, horizontal: 12),
                ),
              ),
              const SizedBox(height: AppDimens.space8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CommandFilter.values
                      .map((f) => _FilterTab(
                            filter: f,
                            isActive: ops.activeFilter == f,
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Liste des commandes
        Expanded(
          child: ops.isLoading
              ? const LoadingState(itemCount: 4)
              : ops.hasError
                  ? ErrorState(
                      onRetry: () =>
                          ref.read(operationsProvider.notifier).refresh(),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(operationsProvider.notifier).refresh(),
                      child: commands.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                EmptyState(
                                  icon: Icons.inbox_outlined,
                                  title: 'Aucune commande trouvée',
                                  message:
                                      'Ajustez vos filtres ou simulez une nouvelle commande depuis le tableau de bord.',
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(
                                  AppDimens.space16),
                              itemCount: commands.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppDimens.space8),
                              itemBuilder: (_, i) => CommandCard(
                                command: commands[i],
                                onTap: () => context.push(
                                    AppRoutes.commandDetailPath(
                                        commands[i].id)),
                              ),
                            ),
                    ),
        ),
      ],
    );
  }
}

class _FilterTab extends ConsumerWidget {
  final CommandFilter filter;
  final bool isActive;

  const _FilterTab({required this.filter, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = switch (filter) {
      CommandFilter.all => 'Tout',
      CommandFilter.pending => 'En attente',
      CommandFilter.confirmed => 'Confirmées',
      CommandFilter.delivering => 'En livraison',
      CommandFilter.completed => 'Livrées',
      CommandFilter.cancelled => 'Annulées',
    };

    return GestureDetector(
      onTap: () =>
          ref.read(operationsProvider.notifier).setFilter(filter),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
