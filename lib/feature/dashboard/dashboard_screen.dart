import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/navigation/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/ui/state_views.dart';
import '../../providers/operations_provider.dart';
import '../commands/command_card.dart';

/// ============================================================
///  ADMIN — ONGLET TABLEAU DE BORD
///  Grille bento de stats + courbe de recettes + pipeline live.
/// ============================================================
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);

    if (ops.isLoading) {
      return const LoadingState(itemCount: 4);
    }

    if (ops.hasError) {
      return ErrorState(
        onRetry: () => ref.read(operationsProvider.notifier).refresh(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.space24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau de bord',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _todayLabel(),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textHint),
                    ),
                  ],
                ),
                Flexible(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () => ref
                        .read(operationsProvider.notifier)
                        .simulateIncomingClientCommand(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Simuler une commande'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space24),
            const _BentoStatsGrid(),
            const SizedBox(height: AppDimens.space24),
            const _RevenueChart(),
            const SizedBox(height: AppDimens.space24),
            const _PipelinePreview(),
            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }
}

// ── Grille bento de statistiques ─────────────────────────────────────────────

class _BentoStatsGrid extends ConsumerWidget {
  const _BentoStatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ops = ref.watch(operationsProvider);

    final stats = [
      _StatDef(
        title: 'Commandes en attente',
        value: ops.pendingCommandsCount.toString(),
        icon: Icons.pending_actions_rounded,
        iconColor: AppColors.pending,
        iconBg: AppColors.pendingSoft,
        trend: '+3 aujourd\'hui',
        trendPositive: true,
      ),
      _StatDef(
        title: 'Livreurs actifs',
        value: ops.activeDeliverersCount.toString(),
        icon: Icons.directions_bike_rounded,
        iconColor: AppColors.delivering,
        iconBg: AppColors.deliveringSoft,
        trend: null,
        trendPositive: true,
      ),
      _StatDef(
        title: 'Livreurs disponibles',
        value: ops.availableDeliverersCount.toString(),
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.success,
        iconBg: AppColors.successSoft,
        trend: null,
        trendPositive: true,
      ),
      _StatDef(
        title: 'Chiffre d\'affaires',
        value: AppConfig.formatPrice(ops.totalRevenue),
        icon: Icons.attach_money_rounded,
        iconColor: AppColors.primary,
        iconBg: AppColors.primaryLight,
        trend: '${ops.completedCount} livrées',
        trendPositive: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 2;

        // Keep every card tall enough for its content (icon row + value +
        // title needs ~132px) regardless of how narrow the slice is.
        final itemWidth =
            (constraints.maxWidth - 12 * (crossAxisCount - 1)) / crossAxisCount;
        final childAspectRatio =
            (itemWidth / 132).clamp(1.2, 2.4);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, i) {
            final s = stats[i];            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 34,
                        height: 34,decoration: BoxDecoration(
                          color: s.iconBg,
                          borderRadius: BorderRadius.circular(AppDimens.radius8),
                        ),
                        child: Icon(s.icon, size: 18, color: s.iconColor),
                      ),
                      if (s.trend != null)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.trendPositive
                                  ? AppColors.successSoft
                                  : AppColors.errorSoft,
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radius8),
                            ),
                            child: Text(
                              s.trend!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: s.trendPositive
                                    ? AppColors.successText
                                    : AppColors.errorText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        s.value,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      s.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatDef {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? trend;
  final bool trendPositive;

  const _StatDef({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.trend,
    required this.trendPositive,
  });
}

// ── Courbe de recettes (CustomPaint natif, sans package) ─────────────────────

class _RevenueChart extends ConsumerWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(
        operationsProvider.select((s) => s.revenueSeries));

    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aperçu du chiffre d\'affaires',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '7 derniers jours',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Cette semaine',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _SmoothLinePainter(
                series: series,
                lineColor: AppColors.chartLine,
                gridColor: AppColors.border,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmoothLinePainter extends CustomPainter {
  final List<double> series;
  final Color lineColor;
  final Color gridColor;

  static const labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  _SmoothLinePainter({
    required this.series,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;

    final maxValue = series.reduce((a, b) => a > b ? a : b) * 1.15;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Lignes horizontales de grille (3)
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Étiquettes des jours
    const labelStyle = TextStyle(fontSize: 10, color: AppColors.textHint);
    for (var i = 0; i < series.length && i < labels.length; i++) {
      final x = zoneCenter(i, series.length, size.width);
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height + 4));
    }

    // Points de la courbe
    final points = <Offset>[];
    final plotHeight = size.height - 24;
    for (var i = 0; i < series.length; i++) {
      final x = zoneCenter(i, series.length, size.width);
      final y = plotHeight * (1 - series[i] / maxValue);
      points.add(Offset(x, y));
    }

    // Courbe lissée (spline de Catmull-Rom simplifiée)
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Aire dégradée sous la courbe
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, plotHeight)
      ..lineTo(points.first.dx, plotHeight)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.18),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, plotHeight));
    canvas.drawPath(fillPath, fillPaint);

    // Trait principal
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  double zoneCenter(int i, int count, double width) {
    final zone = width / count;
    return zone * i + zone / 2;
  }

  @override
  bool shouldRepaint(covariant _SmoothLinePainter oldDelegate) =>
      oldDelegate.series != series;
}

// ── Aperçu du pipeline (3 premières commandes actives) ──────────────────────

class _PipelinePreview extends ConsumerWidget {
  const _PipelinePreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.read(operationsProvider.notifier).filteredCommands;
    final preview = commands.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pipeline des commandes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.commands),
                  child: const Text(
                    'Tout voir →',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.space12),
          const Divider(height: 1),
          if (preview.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 36, color: AppColors.textHint),
                    SizedBox(height: 8),
                    Text(
                      'Aucune commande trouvée',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            )
          else
            ...preview.map((c) => CommandCard(
                  command: c,
                  onTap: () =>
                      context.push(AppRoutes.commandDetailPath(c.id)),
                )),
        ],
      ),
    );
  }
}
