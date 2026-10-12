import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/command_model.dart';
import '../models/deliverer_model.dart';
import '../repositories/operations_repository.dart';
import 'mock_data.dart';

/// ============================================================
///  ADMIN — OPÉRATIONS FICTIVES (MOCK)
/// ============================================================
class MockOperationsRepository implements OperationsRepository {
  final Duration latency;

  MockOperationsRepository({this.latency = const Duration(milliseconds: 600)});

  @override
  Future<List<CommandModel>> fetchCommands() async {
    await Future.delayed(latency);
    return MockData.getInitialCommands();
  }

  @override
  Future<List<DelivererModel>> fetchDeliverers() async {
    await Future.delayed(latency);
    return List.from(MockData.deliverers);
  }

  @override
  Future<List<double>> fetchRevenueSeries() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [820, 1340, 980, 1620, 1180, 1890, 1450];
  }

  @override
  Future<CommandModel> watchIncomingCommand() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.generateRandomIncomingCommand();
  }
}

/// Providers pour injecter le repository des opérations
final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return MockOperationsRepository();
});

/// Utilitaire partagé : générateur pseudo-aléatoire pour la simulation
final simulationRandomProvider = Provider<Random>((ref) => Random());
