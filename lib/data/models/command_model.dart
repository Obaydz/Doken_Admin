import 'deliverer_model.dart';

enum CommandStatus {
  pending, // Commande client passée -> en attente de confirmation admin
  confirmed, // Confirmée par l'admin -> prête pour la collecte
  assigned, // Livreur a accepté / pris la commande
  delivering, // Livreur en route
  completed, // Commande livrée
  cancelled, // Refusée ou annulée
}

/// ============================================================
///  ADMIN — MODÈLE DE COMMANDE
/// ============================================================
class CommandItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? variant; // ex. "Double Patty + Cheddar truffé"
  final String imageUrl;

  const CommandItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.variant,
    required this.imageUrl,
  });

  double get totalPrice => price * quantity;
}

class CommandModel {
  final String id; // ex. "CMD-8021"
  final String clientName;
  final String clientPhone;
  final String clientAvatar;
  final String deliveryAddress;
  final String? instructions;
  final List<CommandItem> items;
  final double deliveryFee;
  final double tip;
  final String paymentMethod; // ex. "Apple Pay", "Visa ****4821", "Espèces"
  final bool isPaid;
  final CommandStatus status;
  final DelivererModel? assignedDeliverer;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final double priorityScore; // priorité 1-10

  const CommandModel({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientAvatar,
    required this.deliveryAddress,
    this.instructions,
    required this.items,
    this.deliveryFee = 3.50,
    this.tip = 2.00,
    required this.paymentMethod,
    this.isPaid = true,
    required this.status,
    this.assignedDeliverer,
    required this.createdAt,
    this.confirmedAt,
    this.priorityScore = 5.0,
  });

  double get subtotal => items.fold(0.0, (acc, item) => acc + item.totalPrice);
  double get grandTotal => subtotal + deliveryFee + tip;

  CommandModel copyWith({
    String? id,
    String? clientName,
    String? clientPhone,
    String? clientAvatar,
    String? deliveryAddress,
    String? instructions,
    List<CommandItem>? items,
    double? deliveryFee,
    double? tip,
    String? paymentMethod,
    bool? isPaid,
    CommandStatus? status,
    DelivererModel? assignedDeliverer,
    DateTime? createdAt,
    DateTime? confirmedAt,
    double? priorityScore,
  }) {
    return CommandModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAvatar: clientAvatar ?? this.clientAvatar,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      instructions: instructions ?? this.instructions,
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tip: tip ?? this.tip,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      assignedDeliverer: assignedDeliverer ?? this.assignedDeliverer,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      priorityScore: priorityScore ?? this.priorityScore,
    );
  }
}
