import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../data/models/command_model.dart';
import '../../providers/operations_provider.dart';
import 'dispatch_confirmation_dialog.dart';
import 'status_badge.dart';

/// ============================================================
///  ADMIN — CARTE DE COMMANDE (actions contextuelles)
/// ============================================================
class CommandCard extends ConsumerWidget {
  final CommandModel command;
  final VoidCallback? onTap;

  const CommandCard({super.key, required this.command, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awaiting =
        ref.watch(operationsProvider).awaitingAcceptance.contains(command.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppDimens.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar client
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: command.clientAvatar.isNotEmpty
                  ? NetworkImage(command.clientAvatar)
                  : null,
              child: command.clientAvatar.isEmpty
                  ? Text(
                      command.clientName.isNotEmpty ? command.clientName[0] : '?',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700))
                  : null,
            ),
            const SizedBox(width: AppDimens.space12),

            // Contenu principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne du haut : client + statut + total
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    command.clientName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge.fromCommandStatus(command.status),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${command.id} · ${_timeAgo(command.createdAt)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _fmt(command.grandTotal),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Adresse
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          command.deliveryAddress,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Articles
                  Text(
                    command.items
                        .map((i) => '${i.quantity}x ${i.name}')
                        .join(' · '),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Livreur attribué
                  if (command.assignedDeliverer != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.directions_bike_rounded,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            command.assignedDeliverer!.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '· ${command.assignedDeliverer!.proximity}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],

                  // Instructions
                  if (command.instructions != null &&
                      command.instructions!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            command.instructions!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textHint),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Boutons d'action
                  _ActionButtons(command: command, awaiting: awaiting),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double value) => value.toStringAsFixed(2).replaceAll('.', ',');

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }
}

// ── Boutons d'action contextuels ─────────────────────────────────────────────

class _ActionButtons extends ConsumerWidget {
  final CommandModel command;
  final bool awaiting;

  const _ActionButtons({required this.command, required this.awaiting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(operationsProvider.notifier);
    final compact = ElevatedButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
    final compactOutlined = OutlinedButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      textStyle: const TextStyle(fontSize: 13),
    );

    final Widget body = switch (command.status) {
      CommandStatus.pending => Row(
          children: [
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => DispatchConfirmationDialog(command: command),
              ),
              style: compact,
              child: const Text('Confirmer'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () =>
                  notifier.cancelCommand(command.id, 'Refusée par l\'admin'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: Size.zero,
                textStyle: const TextStyle(fontSize: 13),
              ),
              child: const Text('Refuser'),
            ),
          ],
        ),
      // Confirmée mais le livreur n'a pas encore accepté/refusé.
      CommandStatus.confirmed when awaiting => Row(
          children: [
            const Icon(Icons.hourglass_top_rounded,
                size: 13, color: AppColors.pending),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'En attente de la réponse de ${command.assignedDeliverer?.name ?? 'un livreur'}…',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.pendingText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      CommandStatus.confirmed => OutlinedButton(
          onPressed: () => notifier.markInTransit(command.id),
          style: compactOutlined,
          child: const Text('Marquer en route'),
        ),
      CommandStatus.assigned => OutlinedButton(
          onPressed: () => notifier.markInTransit(command.id),
          style: compactOutlined,
          child: const Text('Marquer en route'),
        ),
      CommandStatus.delivering => ElevatedButton(
          onPressed: () => notifier.completeCommand(command.id),
          style: compact.copyWith(
            backgroundColor: WidgetStatePropertyAll(AppColors.success),
          ),
          child: const Text('Marquer livrée'),
        ),
      _ => const SizedBox.shrink(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [body],
    );
  }
}
