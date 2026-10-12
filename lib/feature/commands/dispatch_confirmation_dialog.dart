import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../data/models/command_model.dart';
import '../../data/models/deliverer_model.dart';
import '../../providers/operations_provider.dart';

/// ============================================================
///  ADMIN — DIÀLOGUE DE CONFIRMATION DE COMMANDE
///  L'admin ne choisit JAMAIS le livreur ici : la confirmation
///  auto-attribue le meilleur candidat (disponible le plus proche ->
///  le plus proche de finir -> aléatoire), puis le livreur accepte ou
///  refuse sur sa propre app.
/// ============================================================
class DispatchConfirmationDialog extends ConsumerStatefulWidget {
  final CommandModel command;

  const DispatchConfirmationDialog({super.key, required this.command});

  @override
  ConsumerState<DispatchConfirmationDialog> createState() =>
      _DispatchConfirmationDialogState();
}

class _DispatchConfirmationDialogState
    extends ConsumerState<DispatchConfirmationDialog> {
  bool _dispatching = false;

  @override
  Widget build(BuildContext context) {
    final ops = ref.watch(operationsProvider);
    final availableCount = ops.deliverers
        .where((d) => d.status == DelivererStatus.available)
        .length;
    final onMissionCount =
        ops.deliverers.where((d) => d.status == DelivererStatus.busy).length;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Confirmer la commande',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textHint),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Commande ${widget.command.id} · ${widget.command.clientName}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimens.space20),

              // Résumé de la commande
              Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radius12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.command.deliveryAddress,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      '${widget.command.grandTotal.toStringAsFixed(2)} DT',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.space20),

              // Explication de l'auto-attribution
              const Text(
                'Attribution du livreur',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: availableCount > 0
                      ? AppColors.successSoft
                      : AppColors.pendingSoft,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radius12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      availableCount > 0
                          ? Icons.bolt_rounded
                          : Icons.schedule_rounded,
                      size: 16,
                      color: availableCount > 0
                          ? AppColors.successText
                          : AppColors.pendingText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        availableCount > 0
                            ? 'Attribution auto : $availableCount livreur${availableCount == 1 ? '' : 's'} disponible${availableCount == 1 ? '' : 's'} sur son application — le plus proche recevra la commande et devra l\'accepter.'
                            : onMissionCount > 0
                                ? 'Les $onMissionCount livreur${onMissionCount == 1 ? '' : 's'} sont en mission — celui le plus proche de terminer recevra la commande (ou un choix aléatoire sans ETA), et devra l\'accepter sur son application.'
                                : 'Aucun livreur en ligne — la commande est confirmée et sera attribuée automatiquement dès qu\'un livreur sera disponible.',
                        style: TextStyle(
                          fontSize: 13,
                          color: availableCount > 0
                              ? AppColors.successText
                              : AppColors.pendingText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.space24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _dispatching ? null : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _dispatching
                          ? null
                          : () async {
                              setState(() => _dispatching = true);
                              await ref
                                  .read(operationsProvider.notifier)
                                  .confirmCommand(widget.command.id);
                              if (context.mounted) Navigator.pop(context);
                            },
                      child: _dispatching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Confirmer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
