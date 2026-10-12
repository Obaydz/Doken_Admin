import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_app/providers/operations_provider.dart';
import 'package:admin_app/data/models/command_model.dart';

void main() {
  test('Operations pipeline workflow: client order -> admin confirms -> deliverer matched -> delivered', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(operationsProvider.notifier);

    // État initial : au moins une commande en attente
    await Future.delayed(const Duration(seconds: 2)); // chargement initial du mock
    expect(notifier.pendingCommandsCount, greaterThan(0));

    final initialPendingCount = notifier.pendingCommandsCount;
    final firstPending = notifier.filteredCommands
        .firstWhere((c) => c.status == CommandStatus.pending);

    // 1. L'admin confirme la commande -> attribution auto d'un livreur
    await notifier.confirmCommand(firstPending.id);

    expect(notifier.pendingCommandsCount, equals(initialPendingCount - 1));

    final confirmed = container.read(operationsProvider).commands
        .firstWhere((c) => c.id == firstPending.id);
    expect(
      confirmed.status == CommandStatus.confirmed ||
          confirmed.status == CommandStatus.assigned,
      true,
    );
    expect(confirmed.assignedDeliverer, isNotNull);

    // 2. En route
    notifier.markInTransit(confirmed.id);
    expect(
      container.read(operationsProvider).commands
          .firstWhere((c) => c.id == confirmed.id)
          .status,
      CommandStatus.delivering,
    );

    // 3. Livrée
    notifier.completeCommand(confirmed.id);
    final completed = container.read(operationsProvider).commands
        .firstWhere((c) => c.id == confirmed.id);
    expect(completed.status, CommandStatus.completed);
    expect(completed.assignedDeliverer!.completedOrders, greaterThan(0));

    // 4. Nouvelle commande entrante simulée
    final countBefore = notifier.filteredCommands.length;
    await notifier.simulateIncomingClientCommand();
    expect(
      container.read(operationsProvider).commands.length,
      countBefore + 1,
    );
    expect(
      container.read(operationsProvider).commands.first.status,
      CommandStatus.pending,
    );
  });
}
