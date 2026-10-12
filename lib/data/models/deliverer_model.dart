enum DelivererStatus { available, busy, offline }

/// ============================================================
///  ADMIN — MODÈLE LIVREUR
/// ============================================================
class DelivererModel {
  final String id;
  final String name;
  final String phone;
  final String avatar;
  final String vehicle; // ex. "Yamaha MT-07", "Niu E-Scooter", "Trek Cargo"
  final String vehicleIcon;
  final double rating;
  final DelivererStatus status;
  final int completedOrders;
  final String proximity; // ex. "0.8 km"
  final int batteryLevel; // pourcentage

  /// Minutes restantes sur la mission en cours du livreur.
  /// Pertinent uniquement quand le livreur est [DelivererStatus.busy] ;
  /// null quand il est inactif, hors ligne, ou quand son app ne fournit pas d'ETA.
  final int? currentMissionEtaMinutes;

  const DelivererModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatar,
    required this.vehicle,
    required this.vehicleIcon,
    required this.rating,
    required this.status,
    required this.completedOrders,
    required this.proximity,
    required this.batteryLevel,
    this.currentMissionEtaMinutes,
  });

  DelivererModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    String? vehicle,
    String? vehicleIcon,
    double? rating,
    DelivererStatus? status,
    int? completedOrders,
    String? proximity,
    int? batteryLevel,
    int? currentMissionEtaMinutes,
  }) {
    return DelivererModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      vehicle: vehicle ?? this.vehicle,
      vehicleIcon: vehicleIcon ?? this.vehicleIcon,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      completedOrders: completedOrders ?? this.completedOrders,
      proximity: proximity ?? this.proximity,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      currentMissionEtaMinutes:
          currentMissionEtaMinutes ?? this.currentMissionEtaMinutes,
    );
  }

  /// Distance en km extraite de [proximity] (ex. "0.8 km"),
  /// utilisée pour l'auto-attribution. Retourne l'infini si illisible.
  double get proximityKm {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(proximity);
    if (match == null) return double.infinity;
    return double.tryParse(match.group(1)!) ?? double.infinity;
  }

  /// Vrai quand le livreur est en mission ET que son app rapporte une
  /// heure de fin exploitable ("le plus proche de finir").
  bool get hasKnownMissionEta =>
      status == DelivererStatus.busy && currentMissionEtaMinutes != null;
}
