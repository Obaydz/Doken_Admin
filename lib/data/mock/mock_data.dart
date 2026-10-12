import 'dart:math';
import '../models/admin_user_model.dart';
import '../models/command_model.dart';
import '../models/deliverer_model.dart';

/// ============================================================
///  ADMIN — DONNÉES FICTIVES (MOCK)
/// ============================================================
class MockData {
  static const AdminUserModel defaultAdmin = AdminUserModel(
    id: 'ADM-001',
    name: 'Sovereign Nexus',
    email: 'admin@doken.com',
    role: 'Directeur des Opérations',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=250',
  );

  static final List<DelivererModel> deliverers = [
    const DelivererModel(
      id: 'DEL-101',
      name: 'Kai Takahashi',
      phone: '+216 55 234 890',
      avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200',
      vehicle: 'Yamaha MT-07',
      vehicleIcon: 'two_wheeler',
      rating: 4.98,
      status: DelivererStatus.available,
      completedOrders: 342,
      proximity: '0.6 km',
      batteryLevel: 94,
    ),
    const DelivererModel(
      id: 'DEL-102',
      name: 'Elena Rostova',
      phone: '+216 55 876 123',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=200',
      vehicle: 'Niu NQi Cargo',
      vehicleIcon: 'electric_scooter',
      rating: 4.95,
      status: DelivererStatus.available,
      completedOrders: 215,
      proximity: '1.2 km',
      batteryLevel: 88,
    ),
    const DelivererModel(
      id: 'DEL-103',
      name: 'Marcus Vance',
      phone: '+216 55 432 908',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      vehicle: 'Tesla Model Y Livraison',
      vehicleIcon: 'directions_car',
      rating: 4.92,
      status: DelivererStatus.busy,
      completedOrders: 512,
      proximity: '2.8 km',
      batteryLevel: 72,
      currentMissionEtaMinutes: 4, // termine sa course en premier
    ),
    const DelivererModel(
      id: 'DEL-104',
      name: 'Aria Thorne',
      phone: '+216 55 901 445',
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
      vehicle: 'Vélo Electrique Turbo Vado',
      vehicleIcon: 'pedal_bike',
      rating: 4.99,
      status: DelivererStatus.available,
      completedOrders: 180,
      proximity: '0.4 km',
      batteryLevel: 98,
    ),
  ];

  static List<CommandModel> getInitialCommands() {
    return [
      CommandModel(
        id: 'CMD-9042',
        clientName: 'Julien Marchand',
        clientPhone: '+216 55 234 810',
        clientAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
        deliveryAddress: 'Appartement 48B, Tour Apex, Centre-Ville',
        instructions: 'Code ascenseur : #9902. Déposer auprès du concierge.',
        items: const [
          CommandItem(
            id: 'ITM-01',
            name: 'Burger Smashed Wagyu Truffe',
            quantity: 2,
            price: 26.50,
            variant: 'Brioche • Cheddar affiné • Aïoli truffé',
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=300',
          ),
          CommandItem(
            id: 'ITM-02',
            name: 'Chips Parmesan Romarin Ail',
            quantity: 1,
            price: 8.00,
            variant: 'Paprika fumé en supplément',
            imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?auto=format&fit=crop&q=80&w=300',
          ),
          CommandItem(
            id: 'ITM-03',
            name: 'Cold Brew Yuzu Matcha',
            quantity: 2,
            price: 7.50,
            variant: 'Moins de glace • Lait d\'avoine',
            imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&q=80&w=300',
          ),
        ],
        deliveryFee: 4.50,
        tip: 5.00,
        paymentMethod: 'Apple Pay (Instantané)',
        isPaid: true,
        status: CommandStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2, seconds: 15)),
        confirmedAt: null,
        priorityScore: 9.2,
      ),
      CommandModel(
        id: 'CMD-9041',
        clientName: 'Chloé Dubois',
        clientPhone: '+216 55 789 921',
        clientAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        deliveryAddress: 'Lofts Horizon, Suite 1204, Ouest',
        instructions: 'Sonnez deux fois à l\'interphone, je suis en appel.',
        items: const [
          CommandItem(
            id: 'ITM-04',
            name: 'Plateau Sushi Dragon (24 pcs)',
            quantity: 1,
            price: 48.00,
            variant: 'Saumon sauvage • Thon bleu • Unagi',
            imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=300',
          ),
          CommandItem(
            id: 'ITM-05',
            name: 'Edamame Épicés Truffe',
            quantity: 1,
            price: 9.50,
            variant: 'Croûte de sel de mer',
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=300',
          ),
        ],
        deliveryFee: 3.50,
        tip: 8.00,
        paymentMethod: 'Mastercard •••• 9812',
        isPaid: true,
        status: CommandStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5, seconds: 40)),
        confirmedAt: null,
        priorityScore: 8.5,
      ),
      CommandModel(
        id: 'CMD-9040',
        clientName: 'Damien Castellane',
        clientPhone: '+216 55 302 818',
        clientAvatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200',
        deliveryAddress: '744 Chemin Obsidienne, Horizon',
        instructions: 'Déposer devant le porche.',
        items: const [
          CommandItem(
            id: 'ITM-06',
            name: 'Pizza Napolitaine Burrata au Feu de Bois',
            quantity: 2,
            price: 22.00,
            variant: 'Basilic frais • San Marzano DOP',
            imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=300',
          ),
        ],
        deliveryFee: 4.00,
        tip: 4.00,
        paymentMethod: 'Apple Pay',
        isPaid: true,
        status: CommandStatus.confirmed,
        assignedDeliverer: deliverers[0],
        createdAt: DateTime.now().subtract(const Duration(minutes: 14)),
        confirmedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        priorityScore: 7.0,
      ),
      CommandModel(
        id: 'CMD-9039',
        clientName: 'Ségolène Briand',
        clientPhone: '+216 55 667 290',
        clientAvatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&w=200',
        deliveryAddress: 'Villa Aurore, 19 Allée des Palmiers',
        instructions: 'Code portail de sécurité : 1109.',
        items: const [
          CommandItem(
            id: 'ITM-07',
            name: 'Entrecôte Prime Black Angus (400g)',
            quantity: 1,
            price: 54.00,
            variant: 'Saignant • Beurre composé chimichurri',
            imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&q=80&w=300',
          ),
        ],
        deliveryFee: 5.00,
        tip: 10.00,
        paymentMethod: 'Amex •••• 1004',
        isPaid: true,
        status: CommandStatus.delivering,
        assignedDeliverer: deliverers[2],
        createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
        confirmedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        priorityScore: 6.5,
      ),
      CommandModel(
        id: 'CMD-9036',
        clientName: 'Nadia Jelassi',
        clientPhone: '+216 55 145 227',
        clientAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=200',
        deliveryAddress: 'Immeuble Yasmine, Apt 12, La Marsa',
        instructions: 'Laisser devant la porte blanche.',
        items: const [
          CommandItem(
            id: 'ITM-08',
            name: 'Assiette Falafel Signature',
            quantity: 1,
            price: 14.00,
            variant: 'Sauce tahini • Pickles maison',
            imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be5db33?auto=format&fit=crop&q=80&w=300',
          ),
        ],
        deliveryFee: 2.90,
        tip: 3.00,
        paymentMethod: 'Visa •••• 4092',
        isPaid: true,
        status: CommandStatus.completed,
        assignedDeliverer: deliverers[1],
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        confirmedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
        priorityScore: 5.0,
      ),
      CommandModel(
        id: 'CMD-9033',
        clientName: 'Marc Delattre',
        clientPhone: '+216 55 660 128',
        clientAvatar: 'https://images.unsplash.com/photo-1500048993953-d23a436266cf?auto=format&fit=crop&q=80&w=200',
        deliveryAddress: 'Résidence Zénith, Apt 1902, Lac 2',
        instructions: null,
        items: const [
          CommandItem(
            id: 'ITM-09',
            name: 'Wrap Poulet Croustillant',
            quantity: 2,
            price: 11.50,
            variant: 'Sauce blanche à part',
            imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&q=80&w=300',
          ),
        ],
        deliveryFee: 3.00,
        tip: 2.00,
        paymentMethod: 'Espèces à la livraison',
        isPaid: false,
        status: CommandStatus.cancelled,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        confirmedAt: null,
        priorityScore: 4.0,
      ),
    ];
  }

  static CommandModel generateRandomIncomingCommand() {
    final rand = Random();
    final names = [
      'Alexandre Beaumont',
      'Maya Lefèvre',
      'Lucas Vasseur',
      'Zoé Delacroix',
      'Noah Marchand',
      'Valeria Rossi',
    ];
    final addresses = [
      'Résidence Zénith, Apt 1902, Lac 2',
      '84 Boulevard Cyber, Secteur 7',
      'Les Serres Célestes, Penthouse 4',
      'L\'Arcologie, Niveau 32, Quartier B',
    ];
    const dishPool = [
      CommandItem(
        id: 'SIM-01',
        name: 'Bol Wagyu Esprit Fantôme Fumé',
        quantity: 1,
        price: 32.00,
        variant: 'Œuf onsen • Échalotes croustillantes',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=300',
      ),
      CommandItem(
        id: 'SIM-02',
        name: 'Duo de Buns Homard Truffe',
        quantity: 2,
        price: 29.50,
        variant: 'Poché au beurre chaud',
        imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=300',
      ),
      CommandItem(
        id: 'SIM-03',
        name: 'Boba Flottant Cérémonial de Kyoto',
        quantity: 2,
        price: 8.50,
        variant: 'Perles de sucre roux',
        imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&q=80&w=300',
      ),
    ];

    final pickedItems = [
      dishPool[rand.nextInt(dishPool.length)],
      if (rand.nextBool()) dishPool[rand.nextInt(dishPool.length)],
    ];

    final idNumber = 9050 + rand.nextInt(400);

    return CommandModel(
      id: 'CMD-$idNumber',
      clientName: names[rand.nextInt(names.length)],
      clientPhone: '+216 55 ${100 + rand.nextInt(899)} ${1000 + rand.nextInt(8999)}',
      clientAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
      deliveryAddress: addresses[rand.nextInt(addresses.length)],
      instructions: 'Nouvelle commande client reçue en temps réel.',
      items: pickedItems,
      deliveryFee: 4.50,
      tip: (rand.nextInt(8) + 2).toDouble(),
      paymentMethod: rand.nextBool() ? 'Apple Pay' : 'Visa •••• 4092',
      isPaid: true,
      status: CommandStatus.pending,
      createdAt: DateTime.now(),
      priorityScore: (7.0 + rand.nextDouble() * 2.5),
    );
  }
}
