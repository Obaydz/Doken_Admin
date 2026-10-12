import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/ui/state_views.dart';
import '../../data/models/deliverer_model.dart';
import '../../providers/operations_provider.dart';

/// ============================================================
///  ADMIN — ONGLET LIVREURS (flotte en temps réel)
/// ============================================================
class DeliverersScreen extends ConsumerWidget {
  const DeliverersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);

    if (ops.isLoading) return const LoadingState(itemCount: 4);
    if (ops.hasError) {
      return ErrorState(
        onRetry: () => ref.read(operationsProvider.notifier).refresh(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.space16),
      itemCount: ops.deliverers.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.space8),
      itemBuilder: (_, i) => _DelivererCard(ops.deliverers[i]),
    );
  }
}

class _DelivererCard extends StatelessWidget {
  final DelivererModel deliverer;

  const _DelivererCard(this.deliverer);

  Color get _statusColor => switch (deliverer.status) {
        DelivererStatus.available => AppColors.success,
        DelivererStatus.busy => AppColors.pending,
        DelivererStatus.offline => AppColors.textHint,
      };

  String get _statusLabel => switch (deliverer.status) {
        DelivererStatus.available => 'Disponible',
        DelivererStatus.busy => 'En mission',
        DelivererStatus.offline => 'Hors ligne',
      };

  IconData get _vehicleIcon => switch (deliverer.vehicleIcon) {
        'two_wheeler' => Icons.two_wheeler_rounded,
        'electric_scooter' => Icons.electric_scooter_rounded,
        'directions_car' => Icons.directions_car_rounded,
        'pedal_bike' => Icons.pedal_bike_rounded,
        _ => Icons.local_shipping_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.delivererDetailPath(deliverer.id)),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      deliverer.avatar.isNotEmpty
                          ? NetworkImage(deliverer.avatar)
                          : null,
                  child: deliverer.avatar.isEmpty
                      ? Text(
                          deliverer.name.isNotEmpty ? deliverer.name[0] : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deliverer.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.star),
                          Text(
                            deliverer.rating.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(_vehicleIcon,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${deliverer.vehicle} · ${deliverer.proximity}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.battery_std, size: 13,
                          color: AppColors.textHint),
                      const SizedBox(width: 2),
                      Text(
                        '${deliverer.batteryLevel}%',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint),
                      ),
                      const Spacer(),
                      Text(
                        '${deliverer.completedOrders} livraisons',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.space8),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
