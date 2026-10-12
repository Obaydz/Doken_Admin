import '../models/command_model.dart';
import '../models/deliverer_model.dart';

/// ============================================================
///  ADMIN — INTERFACE DU REPOSITORY DES OPÉRATIONS
///  (commandes + livreurs)
/// ============================================================
abstract class OperationsRepository {
  /// Commandes à afficher au démarrage
  Future<List<CommandModel>> fetchCommands();

  /// Livreurs enregistrés
  Future<List<DelivererModel>> fetchDeliverers();

  /// Entrées d'un graphique de recettes sur 7 jours
  Future<List<double>> fetchRevenueSeries();

  /// Nouvelle commande entrante (simulée en temps réel côté back-end)
  Future<CommandModel> watchIncomingCommand();
}
