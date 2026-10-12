import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/mock/mock_operations_repository.dart';
import '../data/models/command_model.dart';
import '../data/models/deliverer_model.dart';

enum CommandFilter { all, pending, confirmed, delivering, completed, cancelled }

/// Stratégie utilisée quand l'admin confirme une commande.
enum AutoMatchStrategy {
  /// Un livreur était libre et disponible (le plus proche).
  available,

  /// Tous occupés : celui le plus proche de finir sa mission.
  closestToFinishing,

  /// Tous occupés, ETA inconnue -> choix aléatoire.
  random,

  /// Personne ne correspond ; la commande reste confirmée jusqu'à
  /// ce qu'un livreur se connecte.
  none,
}

/// ============================================================
///  ADMIN — ÉTAT DES OPÉRATIONS (COMMANDES + LIVREURS)
/// ============================================================
class OperationsState {
  final List<CommandModel> commands;
  final List<DelivererModel> deliverers;
  final CommandFilter activeFilter;
  final String searchQuery;
  final List<double> revenueSeries;
  final bool isLoading;
  final bool hasError;

  /// Commandes envoyées à un livreur mais pas encore acceptées/refusées.
  final Set<String> awaitingAcceptance;

  const OperationsState({
    this.commands = const [],
    this.deliverers = const [],
    this.activeFilter = CommandFilter.all,
    this.searchQuery = '',
    this.revenueSeries = const [],
    this.isLoading = false,
    this.hasError = false,
    this.awaitingAcceptance = const {},
  });

  OperationsState copyWith({
    List<CommandModel>? commands,
    List<DelivererModel>? deliverers,
    CommandFilter? activeFilter,
    String? searchQuery,
    List<double>? revenueSeries,
    bool? isLoading,
    bool? hasError,
    Set<String>? awaitingAcceptance,
  }) {
    return OperationsState(
      commands: commands ?? this.commands,
      deliverers: deliverers ?? this.deliverers,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      revenueSeries: revenueSeries ?? this.revenueSeries,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      awaitingAcceptance: awaitingAcceptance ?? this.awaitingAcceptance,
    );
  }

  // ── Getters dérivés lisibles directement sur l'état ──────────────────
  List<CommandModel> get pendingCommands => commands
      .where((c) => c.status == CommandStatus.pending)
      .toList();

  int get pendingCommandsCount => pendingCommands.length;

  int get activeDeliverersCount =>
      deliverers.where((d) => d.status == DelivererStatus.busy).length;

  int get availableDeliverersCount =>
      deliverers.where((d) => d.status == DelivererStatus.available).length;

  double get totalRevenue => commands
      .where((c) =>
          c.isPaid &&
          c.status != CommandStatus.cancelled &&
          c.status != CommandStatus.pending)
      .fold(0.0, (acc, c) => acc + c.grandTotal);

  int get completedCount =>
      commands.where((c) => c.status == CommandStatus.completed).length;
}

class OperationsNotifier extends StateNotifier<OperationsState> {
  final Ref _ref;

  /// Bandeau de notification temps réel (le plus récent en tête)
  final List<String> _alerts = [];
  final _alertsController = StreamController<String>.broadcast();

  OperationsNotifier(this._ref) : super(const OperationsState(isLoading: true)) {
    _loadInitialData();
  }

  Stream<String> get alertStream => _alertsController.stream;
  List<String> get alerts => List.unmodifiable(_alerts);

  // ── Chargement initial ────────────────────────────────────────────────────
  Future<void> _loadInitialData() async {
    try {
      final repo = _ref.read(operationsRepositoryProvider);
      final results = await Future.wait([
        repo.fetchCommands(),
        repo.fetchDeliverers(),
        repo.fetchRevenueSeries(),
      ]);

      if (!mounted) return;
      state = state.copyWith(
        commands: results[0] as List<CommandModel>,
        deliverers: results[1] as List<DelivererModel>,
        revenueSeries: results[2] as List<double>,
        isLoading: false,
        hasError: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadInitialData();
  }

  // ── Getters dérivés ───────────────────────────────────────────────────────
  List<CommandModel> get filteredCommands {
    return state.commands.where((cmd) {
      final matchesStatus = switch (state.activeFilter) {
        CommandFilter.all => true,
        CommandFilter.pending => cmd.status == CommandStatus.pending,
        CommandFilter.confirmed =>
          cmd.status == CommandStatus.confirmed ||
              cmd.status == CommandStatus.assigned,
        CommandFilter.delivering => cmd.status == CommandStatus.delivering,
        CommandFilter.completed => cmd.status == CommandStatus.completed,
        CommandFilter.cancelled => cmd.status == CommandStatus.cancelled,
      };

      final q = state.searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          cmd.id.toLowerCase().contains(q) ||
          cmd.clientName.toLowerCase().contains(q) ||
          cmd.deliveryAddress.toLowerCase().contains(q);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  List<CommandModel> get pendingCommands => state.commands
      .where((c) => c.status == CommandStatus.pending)
      .toList();

  int get pendingCommandsCount => pendingCommands.length;

  int get activeDeliverersCount =>
      state.deliverers.where((d) => d.status == DelivererStatus.busy).length;

  int get availableDeliverersCount => state.deliverers
      .where((d) => d.status == DelivererStatus.available)
      .length;

  double get totalRevenue => state.commands
      .where((c) =>
          c.isPaid &&
          c.status != CommandStatus.cancelled &&
          c.status != CommandStatus.pending)
      .fold(0.0, (acc, c) => acc + c.grandTotal);

  int get completedCount =>
      state.commands.where((c) => c.status == CommandStatus.completed).length;

  bool isAwaitingAcceptance(String commandId) =>
      state.awaitingAcceptance.contains(commandId);

  // ── Filtre & recherche ────────────────────────────────────────────────────
  void setFilter(CommandFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  void _postAlert(String message) {
    _alerts.insert(0, message);
    if (_alerts.length > 5) _alerts.removeLast();
    if (!_alertsController.isClosed) {
      _alertsController.add(message);
    }
    state = state.copyWith();
  }

  void dismissAlert(String message) {
    _alerts.remove(message);
    state = state.copyWith();
  }

  void clearAlerts() {
    _alerts.clear();
    state = state.copyWith();
  }

  // ── LE PIPELINE PRINCIPAL ─────────────────────────────────────────────────
  // 1. Le client passe une commande -> l'admin confirme -> auto-attribution.
  //    Le livreur (sur sa propre app) accepte ou refuse ensuite.
  //    L'admin ne sélectionne jamais le livreur manuellement.
  Future<void> confirmCommand(String commandId) async {
    final index = state.commands.indexWhere((c) => c.id == commandId);
    if (index == -1) return;

    final targetCommand = state.commands[index];
    final match = _autoMatchDeliverer();
    final assigned = match?.deliverer;

    if (assigned != null) {
      final updatedDeliverers = [...state.deliverers];
      final dIndex = updatedDeliverers.indexWhere((d) => d.id == assigned.id);
      if (dIndex != -1) {
        updatedDeliverers[dIndex] = updatedDeliverers[dIndex].copyWith(
          status: assigned.status == DelivererStatus.available
              ? DelivererStatus.busy
              : assigned.status,
        );
      }
      state = state.copyWith(deliverers: updatedDeliverers);
    }

    final updatedCommands = [...state.commands];
    updatedCommands[index] = targetCommand.copyWith(
      status: CommandStatus.confirmed,
      confirmedAt: DateTime.now(),
      assignedDeliverer: assigned,
    );
    state = state.copyWith(commands: updatedCommands);

    if (assigned != null) {
      // Le livreur voit l'offre sur son app et doit l'accepter.
      state = state.copyWith(
        awaitingAcceptance: {...state.awaitingAcceptance, targetCommand.id},
      );
      _postAlert(_matchAlert(targetCommand.id, assigned, match!.strategy));
      unawaited(_simulateDelivererDecision(targetCommand.id, assigned));
    } else {
      _postAlert(
        'Commande #${targetCommand.id} confirmée ! Aucun livreur en ligne — attribution auto dès qu\'un livreur sera disponible.',
      );
    }

    // Si tous les livreurs étaient occupés, celui le plus proche de finir
    // redeviendra disponible sous peu : la commande est mise en file.
    if (assigned == null) {
      _queueWatchForAvailableDeliverer(targetCommand.id);
    }
  }

  /// Logique d'auto-attribution (sans intervention admin) :
  ///  1. Tout livreur disponible sur son app -> le plus proche gagne.
  ///  2. Sinon, livreurs occupés avec ETA connue -> celui qui finit le plus tôt.
  ///  3. Sinon, livreurs occupés sans ETA -> choix aléatoire.
  ///  4. Sinon null (tout le monde hors ligne / occupé sans ETA géré plus haut).
  _AutoMatch? _autoMatchDeliverer() {
    final available = state.deliverers
        .where((d) => d.status == DelivererStatus.available)
        .toList()
      ..sort((a, b) => a.proximityKm.compareTo(b.proximityKm));
    if (available.isNotEmpty) {
      return _AutoMatch(available.first, AutoMatchStrategy.available);
    }

    final busyWithEta =
        state.deliverers.where((d) => d.hasKnownMissionEta).toList();
    if (busyWithEta.isNotEmpty) {
      busyWithEta.sort(
        (a, b) => (a.currentMissionEtaMinutes!)
            .compareTo(b.currentMissionEtaMinutes!),
      );
      return _AutoMatch(busyWithEta.first, AutoMatchStrategy.closestToFinishing);
    }

    final busyEveryone =
        state.deliverers.where((d) => d.status == DelivererStatus.busy).toList();
    if (busyEveryone.isNotEmpty) {
      final rand = _ref.read(simulationRandomProvider);
      return _AutoMatch(
        busyEveryone[rand.nextInt(busyEveryone.length)],
        AutoMatchStrategy.random,
      );
    }

    return null;
  }

  String _matchAlert(
      String commandId, DelivererModel deliverer, AutoMatchStrategy strategy) {
    final reason = switch (strategy) {
      AutoMatchStrategy.available =>
        'livreur disponible le plus proche (${deliverer.proximity})',
      AutoMatchStrategy.closestToFinishing =>
        'le plus proche de finir sa mission en cours (~${deliverer.currentMissionEtaMinutes} min restantes)',
      AutoMatchStrategy.random =>
        'choix aléatoire (tous en mission, ETA inconnue)',
      AutoMatchStrategy.none => 'en file d\'attente',
    };
    return 'Commande #$commandId attribuée à ${deliverer.name} — $reason. En attente de son acceptation.';
  }

  /// Simule ce que fait l'app du livreur : il voit l'offre entrante et
  /// l'accepte ou la refuse. S'il refuse, l'offre passe au livreur
  /// correspondant suivant.
  Future<void> _simulateDelivererDecision(
    String commandId,
    DelivererModel deliverer,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || _maybeBailIfCancelled(commandId)) return;

    // ~1 offre sur 4 est refusée, comme dans la vraie vie.
    final rand = _ref.read(simulationRandomProvider);
    final accepts = rand.nextInt(4) != 0;
    if (accepts) {
      final awaiting = {...state.awaitingAcceptance}..remove(commandId);
      final updatedCommands = [...state.commands];
      final index = updatedCommands.indexWhere((c) => c.id == commandId);
      if (index != -1) {
        updatedCommands[index] =
            updatedCommands[index].copyWith(status: CommandStatus.assigned);
      }
      state = state.copyWith(
        commands: updatedCommands,
        awaitingAcceptance: awaiting,
      );
      _postAlert('${deliverer.name} a accepté la commande #$commandId.');
    } else {
      _postAlert(
          '${deliverer.name} a refusé la commande #$commandId — nouvelle recherche…');
      // Nouvelle tentative contre les livreurs restants.
      final next = _autoMatchDeliverer();
      final index = state.commands.indexWhere((c) => c.id == commandId);
      if (index == -1) return;
      if (next != null) {
        // Offre au prochain meilleur candidat.
        await _simulateDelivererDecision(commandId, next.deliverer);
      } else {
        final awaiting = {...state.awaitingAcceptance}..remove(commandId);
        final updatedCommands = [...state.commands];
        updatedCommands[index] = updatedCommands[index]
            .copyWith(assignedDeliverer: null)
            .copyWith(
              assignedDeliverer: null,
            );
        state = state.copyWith(
          commands: updatedCommands,
          awaitingAcceptance: awaiting,
        );
        _postAlert(
          'Aucun livreur disponible pour #$commandId — en attente qu\'un livreur se connecte.',
        );
        _queueWatchForAvailableDeliverer(commandId);
      }
    }
  }

  /// Attend qu'un livreur devienne disponible, puis attribue
  /// automatiquement la commande en file (confirmée non attribuée).
  void _queueWatchForAvailableDeliverer(String commandId) {
    Timer(const Duration(seconds: 6), () async {
      if (!mounted || _maybeBailIfCancelled(commandId)) return;

      final index = state.commands.indexWhere((c) => c.id == commandId);
      if (index == -1) return;
      final cmd = state.commands[index];
      if (cmd.assignedDeliverer != null) return;
      if (cmd.status == CommandStatus.cancelled ||
          cmd.status == CommandStatus.completed) {
        return;
      }

      final match = _autoMatchDeliverer();
      if (match == null) {
        // Toujours personne de libre — on continue d'attendre.
        _queueWatchForAvailableDeliverer(commandId);
        return;
      }

      final assigned = match.deliverer;
      final updatedDeliverers = [...state.deliverers];
      final dIndex = updatedDeliverers.indexWhere((d) => d.id == assigned.id);
      if (dIndex != -1) {
        updatedDeliverers[dIndex] =
            updatedDeliverers[dIndex].copyWith(status: DelivererStatus.busy);
      }
      final updatedCommands = [...state.commands];
      updatedCommands[index] = cmd.copyWith(assignedDeliverer: assigned);
      state = state.copyWith(
        commands: updatedCommands,
        deliverers: updatedDeliverers,
        awaitingAcceptance: {...state.awaitingAcceptance, commandId},
      );
      _postAlert(_matchAlert(commandId, assigned, match.strategy));
      unawaited(_simulateDelivererDecision(commandId, assigned));
    });
  }

  /// Vrai quand la commande a été annulée/terminée avant que la décision
  /// simulée du livreur (ou le poll) ne se déclenche ; stoppe les actions
  /// obsolètes.
  bool _maybeBailIfCancelled(String commandId) {
    final index = state.commands.indexWhere((c) => c.id == commandId);
    final cmd = index == -1 ? null : state.commands[index];
    return cmd == null ||
        cmd.status == CommandStatus.cancelled ||
        cmd.status == CommandStatus.completed;
  }

  // ── Actions de suivi ──────────────────────────────────────────────────────

  /// 2. En route
  void markInTransit(String commandId) {
    final index = state.commands.indexWhere((c) => c.id == commandId);
    if (index == -1) return;

    final updatedCommands = [...state.commands];
    updatedCommands[index] =
        updatedCommands[index].copyWith(status: CommandStatus.delivering);
    state = state.copyWith(commands: updatedCommands);
    _postAlert('Livreur en route pour #${updatedCommands[index].id}.');
  }

  /// 3. Terminer la commande
  void completeCommand(String commandId) {
    final index = state.commands.indexWhere((c) => c.id == commandId);
    if (index == -1) return;

    final cmd = state.commands[index];
    if (cmd.assignedDeliverer != null) {
      final updatedDeliverers = [...state.deliverers];
      final dIndex = updatedDeliverers
          .indexWhere((d) => d.id == cmd.assignedDeliverer!.id);
      if (dIndex != -1) {
        updatedDeliverers[dIndex] = updatedDeliverers[dIndex].copyWith(
          status: DelivererStatus.available,
          completedOrders: updatedDeliverers[dIndex].completedOrders + 1,
        );
      }
      state = state.copyWith(deliverers: updatedDeliverers);
    }

    final updatedCommands = [...state.commands];
    updatedCommands[index] = cmd.copyWith(status: CommandStatus.completed);
    state = state.copyWith(commands: updatedCommands);
    _postAlert('Commande #${cmd.id} livrée avec succès !');
  }

  /// 4. Annuler / refuser la commande
  void cancelCommand(String commandId, String reason) {
    final index = state.commands.indexWhere((c) => c.id == commandId);
    if (index == -1) return;

    final updatedCommands = [...state.commands];
    updatedCommands[index] =
        updatedCommands[index].copyWith(status: CommandStatus.cancelled);
    final awaiting = {...state.awaitingAcceptance}..remove(commandId);
    state = state.copyWith(
      commands: updatedCommands,
      awaitingAcceptance: awaiting,
    );
    _postAlert('Commande #${state.commands[index].id} annulée.');
  }

  /// 5. Simuler une commande client entrante en temps réel
  Future<void> simulateIncomingClientCommand() async {
    final repo = _ref.read(operationsRepositoryProvider);
    final newCommand = await repo.watchIncomingCommand();
    if (!mounted) return;

    state = state.copyWith(
      commands: [newCommand, ...state.commands],
    );
    _postAlert(
      '🔥 NOUVELLE COMMANDE CLIENT : #${newCommand.id} de ${newCommand.clientName} (${AppConfig.formatPrice(newCommand.grandTotal)})',
    );
  }

  @override
  void dispose() {
    _alertsController.close();
    super.dispose();
  }
}

/// Le candidat choisi par l'auto-attribution plus la stratégie utilisée.
class _AutoMatch {
  final DelivererModel deliverer;
  final AutoMatchStrategy strategy;

  const _AutoMatch(this.deliverer, this.strategy);
}

/// Provider principal des opérations
final operationsProvider =
    StateNotifierProvider<OperationsNotifier, OperationsState>((ref) {
  return OperationsNotifier(ref);
});

/// Provider réactif pour le bandeau d'alertes temps réel
final alertsListProvider = Provider<List<String>>((ref) {
  final notifier = ref.watch(operationsProvider.notifier);
  // notifier.alerts est lu à chaque rebuild déclenché par state
  ref.listen(operationsProvider, (_, _) {});
  return notifier.alerts;
});
