import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/ui/app_top_bar.dart';
import '../../core/ui/state_views.dart';
import '../../data/models/command_model.dart';
import '../../data/models/deliverer_model.dart';
import '../../providers/operations_provider.dart';

/// ============================================================
///  ADMIN — DÉTAIL D'UN LIVREUR
/// ============================================================
class DelivererDetailScreen extends ConsumerWidget {
  final String delivererId;

  const DelivererDetailScreen({super.key, required this.delivererId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);
    final deliverer =
        ops.deliverers.where((d) => d.id == delivererId).firstOrNull;

    if (deliverer == null) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Livreur', showBackButton: true),
        body: const EmptyState(
          icon: Icons.directions_bike_outlined,
          title: 'Livreur introuvable',
          message: 'Ce livreur n\'existe pas ou a été retiré.',
        ),
      );
    }

    final currentDeliveries = ops.commands
        .where((c) =>
            c.assignedDeliverer?.id == deliverer.id &&
            c.status != CommandStatus.completed &&
            c.status != CommandStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppTopBar(title: deliverer.name, showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profil
            Container(
              padding: const EdgeInsets.all(AppDimens.space24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radius16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: deliverer.avatar.isNotEmpty
                        ? NetworkImage(deliverer.avatar)
                        : null,
                    child: deliverer.avatar.isEmpty
                        ? Text(
                            deliverer.name.isNotEmpty
                                ? deliverer.name[0]
                                : '?',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary))
                        : null,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  Text(
                    deliverer.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deliverer.phone,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimens.space16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Pill(
                        icon: Icons.star_rounded,
                        label: deliverer.rating.toStringAsFixed(2),
                        color: AppColors.star,
                      ),
                      const SizedBox(width: 8),
                      _Pill(
                        icon: Icons.inventory_rounded,
                        label: '${deliverer.completedOrders} livraisons',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space16),

            // État live
            Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radius16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'État en direct',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  _InfoRow(
                    icon: Icons.circle,
                    label: 'Statut',
                    value: switch (deliverer.status) {
                      DelivererStatus.available => 'Disponible',
                      DelivererStatus.busy => 'En mission',
                      DelivererStatus.offline => 'Hors ligne',
                    },
                  ),
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Véhicule',
                    value: deliverer.vehicle,
                  ),
                  _InfoRow(
                    icon: Icons.near_me_outlined,
                    label: 'Proximité',
                    value: deliverer.proximity,
                  ),
                  _InfoRow(
                    icon: Icons.battery_std,
                    label: 'Batterie',
                    value: '${deliverer.batteryLevel}%',
                  ),
                  if (deliverer.currentMissionEtaMinutes != null)
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'ETA mission',
                      value:
                          '~${deliverer.currentMissionEtaMinutes} min restantes',
                    ),
                  // Jauge batterie
                  const SizedBox(height: AppDimens.space8),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusFull),
                    child: LinearProgressIndicator(
                      value: deliverer.batteryLevel / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceAlt,
                      color: deliverer.batteryLevel > 20
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space16),

            // Livraisons en cours
            Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radius16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Livraisons actives (${currentDeliveries.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  if (currentDeliveries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
                      child: Text(
                        'Aucune livraison active pour ce livreur.',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textHint),
                      ),
                    )
                  else
                    ...currentDeliveries.map((c) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimens.space8),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt_long_outlined,
                                  size: 15, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '#${c.id} · ${c.clientName}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textHint),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textHint)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
