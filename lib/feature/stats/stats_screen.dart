import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/ui/state_views.dart';
import '../../data/models/command_model.dart';
import '../../providers/operations_provider.dart';

/// ============================================================
///  ADMIN — ONGLET STATISTIQUES
///  Résumé KPI + répartition par statut + mini-courbe.
/// ============================================================
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);

    if (ops.isLoading) return const LoadingState(itemCount: 4);
    if (ops.hasError) {
      return ErrorState(
        onRetry: () => ref.read(operationsProvider.notifier).refresh(),
      );
    }

    final byStatus = <String, int>{
      'En attente': ops.commands.where((c) => c.status == CommandStatus.pending).length,
      'Confirmées': ops.commands
          .where((c) =>
              c.status == CommandStatus.confirmed ||
              c.status == CommandStatus.assigned)
          .length,
      'En livraison': ops.commands
          .where((c) => c.status == CommandStatus.delivering)
          .length,
      'Livrées':
          ops.commands.where((c) => c.status == CommandStatus.completed).length,
      'Annulées':
          ops.commands.where((c) => c.status == CommandStatus.cancelled).length,
    };
    final maxStatus = byStatus.values.fold(1, (a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI principaux
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'CA encaissé',
                  value: AppConfig.formatPrice(ops.totalRevenue),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: _KpiCard(
                  label: 'Livrées',
                  value: '${ops.completedCount}',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space12),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'File d\'attente',
                  value: '${ops.pendingCommandsCount}',
                  color: AppColors.pending,
                ),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: _KpiCard(
                  label: 'Flotte active',
                  value:
                      '${ops.activeDeliverersCount}/${ops.deliverers.length}',
                  color: AppColors.delivering,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space24),

          // Répartition par statut
          Container(
            padding: const EdgeInsets.all(AppDimens.space20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radius16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Répartition des commandes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimens.space16),
                ...byStatus.entries.map((e) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimens.space12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary),
                              ),
                              Text(
                                '${e.value}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimens.radiusFull),
                            child: LinearProgressIndicator(
                              value: e.value / maxStatus,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceAlt,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          // Courbe de recettes
          Container(
            padding: const EdgeInsets.all(AppDimens.space20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radius16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recettes — 7 derniers jours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimens.space16),
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _MiniBarPainter(
                      series: ops.revenueSeries,
                      barColor: AppColors.chartLine,
                      gridColor: AppColors.border,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space32),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _MiniBarPainter extends CustomPainter {
  final List<double> series;
  final Color barColor;
  final Color gridColor;

  static const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  _MiniBarPainter({
    required this.series,
    required this.barColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final maxValue = series.reduce((a, b) => a > b ? a : b) * 1.1;
    final plotHeight = size.height - 24;
    final zone = size.width / series.length;
    final barWidth = zone * 0.5;
    final paint = Paint()..color = barColor;

    for (var i = 0; i < series.length && i < labels.length; i++) {
      final h = plotHeight * series[i] / maxValue;
      final x = zone * i + (zone - barWidth) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, plotHeight - h, barWidth, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
    }

    // Ligne de base
    final basePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, plotHeight),
        Offset(size.width, plotHeight), basePaint);

    // Étiquettes des jours
    const labelStyle = TextStyle(fontSize: 10, color: AppColors.textHint);
    for (var i = 0; i < series.length && i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(
        zone * i + zone / 2 - tp.width / 2,
        plotHeight + 6,
      ));
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBarPainter oldDelegate) =>
      oldDelegate.series != series;
}
