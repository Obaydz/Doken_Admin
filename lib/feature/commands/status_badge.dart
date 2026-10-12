import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../data/models/command_model.dart';

/// ============================================================
///  ADMIN — BADGE DE STATUT (couleur + point + texte)
/// ============================================================
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    required this.textColor,
  });

  static StatusBadge fromCommandStatus(CommandStatus status) {
    return switch (status) {
      CommandStatus.pending => const StatusBadge(
          label: 'En attente',
          color: AppColors.pending,
          background: AppColors.pendingSoft,
          textColor: AppColors.pendingText,
        ),
      CommandStatus.confirmed => const StatusBadge(
          label: 'Confirmée',
          color: AppColors.confirmed,
          background: AppColors.confirmedSoft,
          textColor: AppColors.confirmedText,
        ),
      CommandStatus.assigned => const StatusBadge(
          label: 'Attribuée',
          color: AppColors.confirmed,
          background: AppColors.confirmedSoft,
          textColor: AppColors.confirmedText,
        ),
      CommandStatus.delivering => const StatusBadge(
          label: 'En livraison',
          color: AppColors.delivering,
          background: AppColors.deliveringSoft,
          textColor: AppColors.deliveringText,
        ),
      CommandStatus.completed => const StatusBadge(
          label: 'Livrée',
          color: AppColors.success,
          background: AppColors.successSoft,
          textColor: AppColors.successText,
        ),
      CommandStatus.cancelled => const StatusBadge(
          label: 'Annulée',
          color: AppColors.error,
          background: AppColors.errorSoft,
          textColor: AppColors.errorText,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
