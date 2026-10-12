import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/ui/app_top_bar.dart';
import '../../core/ui/state_views.dart';
import '../../data/models/command_model.dart';
import '../../providers/operations_provider.dart';
import 'dispatch_confirmation_dialog.dart';
import 'status_badge.dart';

/// ============================================================
///  ADMIN — DÉTAIL D'UNE COMMANDE
/// ============================================================
class CommandDetailScreen extends ConsumerWidget {
  final String commandId;

  const CommandDetailScreen({super.key, required this.commandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);
    final command =
        ops.commands.where((c) => c.id == commandId).firstOrNull;

    if (command == null) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Commande', showBackButton: true),
        body: const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Commande introuvable',
          message: 'Cette commande n\'existe plus ou a été supprimée.',
        ),
      );
    }

    return Scaffold(
      appBar: AppTopBar(title: command.id, showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête statut
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          command.clientName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      StatusBadge.fromCommandStatus(command.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    command.clientPhone,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const Divider(height: AppDimens.space24),
                  _Row(
                    icon: Icons.location_on_outlined,
                    label: 'Adresse',
                    value: command.deliveryAddress,
                  ),
                  if (command.instructions != null &&
                      command.instructions!.isNotEmpty)
                    _Row(
                      icon: Icons.info_outline_rounded,
                      label: 'Instructions',
                      value: command.instructions!,
                    ),
                  _Row(
                    icon: Icons.payments_outlined,
                    label: 'Paiement',
                    value:
                        '${command.paymentMethod} · ${command.isPaid ? "payée" : "à la livraison"}',
                  ),
                  _Row(
                    icon: Icons.schedule_rounded,
                    label: 'Reçue',
                    value: _fmtDate(command.createdAt),
                  ),
                  if (command.confirmedAt != null)
                    _Row(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Confirmée',
                      value: _fmtDate(command.confirmedAt!),
                    ),
                  if (command.assignedDeliverer != null)
                    _Row(
                      icon: Icons.directions_bike_rounded,
                      label: 'Livreur',
                      value:
                          '${command.assignedDeliverer!.name} · ${command.assignedDeliverer!.proximity} · ${command.assignedDeliverer!.vehicle}',
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space16),

            // Articles
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
                    'Articles (${command.items.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimens.space12),
                  ...command.items.map((item) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimens.space12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radius8),
                              child: Image.network(
                                item.imageUrl,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.surfaceAlt,
                                  child: const Icon(Icons.fastfood_rounded,
                                      size: 20, color: AppColors.textHint),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.quantity}x ${item.name}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (item.variant != null)
                                    Text(
                                      item.variant!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textHint),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              AppConfig.formatPrice(item.totalPrice),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  _Row(
                    icon: Icons.receipt_outlined,
                    label: 'Sous-total',
                    value: AppConfig.formatPrice(command.subtotal),
                  ),
                  _Row(
                    icon: Icons.local_shipping_outlined,
                    label: 'Frais de livraison',
                    value: AppConfig.formatPrice(command.deliveryFee),
                  ),
                  _Row(
                    icon: Icons.volunteer_activism_outlined,
                    label: 'Pourboire',
                    value: AppConfig.formatPrice(command.tip),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        AppConfig.formatPrice(command.grandTotal),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space16),

            // Actions
            _DetailActions(commandId: command.id),
            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} à ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textHint),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textHint),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends ConsumerWidget {
  final String commandId;

  const _DetailActions({required this.commandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);
    final command =
        ops.commands.where((c) => c.id == commandId).firstOrNull;
    final notifier = ref.read(operationsProvider.notifier);

    if (command == null) return const SizedBox.shrink();
    final awaiting = ops.awaitingAcceptance.contains(command.id);

    return switch (command.status) {
      CommandStatus.pending => Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => DispatchConfirmationDialog(command: command),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Confirmer la commande'),
            ),
            const SizedBox(height: AppDimens.space8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () => notifier.cancelCommand(commandId, 'Refusée'),
              child: const Text('Refuser la commande'),
            ),
          ],
        ),
      CommandStatus.confirmed when awaiting => Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.pendingSoft,
            borderRadius: BorderRadius.circular(AppDimens.radius16),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded,
                  size: 16, color: AppColors.pendingText),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'En attente de la réponse du livreur sur son application…',
                  style: TextStyle(fontSize: 13, color: AppColors.pendingText),
                ),
              ),
            ],
          ),
        ),
      CommandStatus.confirmed || CommandStatus.assigned => ElevatedButton(
          onPressed: () => notifier.markInTransit(commandId),
          child: const Text('Marquer en route'),
        ),
      CommandStatus.delivering => ElevatedButton(
          onPressed: () => notifier.completeCommand(commandId),
          child: const Text('Marquer livrée'),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
