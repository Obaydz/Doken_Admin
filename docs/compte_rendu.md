# doken Admin — Documentation

**Application d'administration** de la plateforme de livraison multi-vendeurs doken (Tunisie). Écrite en Flutter, elle reprend exactement l'architecture et le design system de l'application client (`doken_client-main`).

## 1. Stack technique

| Composant | Choix |
|---|---|
| Framework | Flutter (Material 3) |
| State management | `flutter_riverpod` (StateNotifier) |
| Navigation | `go_router` (StatefulShellRoute.indexedStack) |
| Données | Mocks injectés derrière des interfaces de repository |

## 2. Structure du code

```
lib/
├── main.dart / app.dart          Point d'entrée + MaterialApp.router (thème, router)
├── core/
│   ├── config/app_config.dart    Constantes (devise TND, formatage prix)
│   ├── navigation/               Routes, AppRouter, DashboardShell (barre 3 onglets)
│   ├── session/                  Session admin (StateNotifier)
│   ├── theme/                    AppColors (palette unique), AppTheme, AppDimens
│   ├── ui/                       Composants réutilisables: AppFormField, AppTopBar,
│   │                             EmptyState / ErrorState / LoadingState / Shimmer
│   └── utils/                    Validation email / mot de passe
├── data/
│   ├── models/                   AdminUser, Command, Deliverer (enums + json)
│   ├── repositories/             Interfaces AuthRepository + OperationsRepository
│   └── mock/                     Implémentations mock + données de démo (MockData)
├── providers/
│   └── operations_provider.dart  Cœur métier (voir §4)
└── feature/
    ├── splash/                   Écran de démarrage → vérifie la session
    ├── auth/                     Connexion (admin@doken.com / Admin1234)
    ├── dashboard/                KPIs, alerte temps réel, file d'attente, courbe de
    │                             recettes (CustomPaint natif), simulation commande
    ├── commands/                 Liste (recherche + filtres), carte, écran détail,
    │                             badge de statut, dialogue de confirmation
    ├── deliverers/               Flotte + écran détail livreur (statut, batterie,
    │                             livraisons actives, position)
    └── stats/                    KPIs, répartition par statut, graphique de recettes
```

## 3. Interfaces (les écrans)

### 3.1 Splash & Connexion
Écran de démarrage avec logo, puis connexion par identifiants. La session est conservée par `SessionNotifier` ; redirection automatique selon l'état.
**Identifiants de démo : `admin@doken.com` / `Admin1234`**

> 🖼️ **[ INSÉRER IMAGE : Écran Splash ]**

> 🖼️ **[ INSÉRER IMAGE : Écran de connexion ]**

### 3.2 Dashboard
Vue ops temps réel : bandeau d'alerte (nouvelle commande / livreur refuse), grille de 4 KPI (commandes en attente, livreurs actifs, disponibles, chiffre d'affaires), file d'attente des commandes, bouton « simuler une commande entrante ».

> 🖼️ **[ INSÉRER IMAGE : Dashboard ]**

### 3.3 Commandes
Liste filtrable (recherche + onglets de statut) avec cartes de commande ; écran détail (articles, adresse, paiement, timeline) et dialogue de confirmation déclenchant l'**attribution automatique** d'un livreur — l'admin ne choisit jamais lui-même le livreur.

> 🖼️ **[ INSÉRER IMAGE : Liste des commandes ]**

> 🖼️ **[ INSÉRER IMAGE : Détail d'une commande ]**

> 🖼️ **[ INSÉRER IMAGE : Dialogue de confirmation d'attribution ]**

### 3.4 Livreurs
Flotte en direct : statut (disponible / en mission / hors ligne), véhicule, note, batterie. Détail par livreur : livraisons actives, position, historique.

> 🖼️ **[ INSÉRER IMAGE : Flotte des livreurs ]**

> 🖼️ **[ INSÉRER IMAGE : Détail d'un livreur ]**

### 3.5 Statistiques
KPIs, barres de répartition par statut et courbe des recettes sur 7 jours dessinée en `CustomPaint` natif (aucun package de graphiques).

> 🖼️ **[ INSÉRER IMAGE : Statistiques ]**

## 4. Logique métier (`lib/providers/operations_provider.dart`)

- **Attribution automatique** : à la confirmation d'une commande, sélection du livreur dans cet ordre — ① le plus proche **disponible** → ② le plus proche **de fin de mission** (ETA minimale) → ③ aléatoire. Le livreur doit ensuite **accepter ou refuser** sur sa propre application (~1 refus sur 4, simulé).
- **File d'attente** : si aucun livreur n'est en ligne, la commande confirmée reste en attente et sera attribuée dès qu'un livreur se libère.
- **Cycle de statut** : `pending → confirmed → en-route → delivered` (ou `cancelled`), avec mise à jour du paiement, du total et de la timeline.
- **Temps réel simulé** : un minuteur interne fait avancer positions/ETA des livreurs et déclenche les alertes.

## 5. Interfaces de code (points d'extension)

Les repositories sont des **interfaces** (`abstract class`) : pour brancher un vrai backend, il suffit de fournir une nouvelle implémentation sans toucher au provider ni aux écrans.

| Interface | Rôle |
|---|---|
| `AuthRepository` | Connexion / déconnexion administrateur |
| `OperationsRepository` | Streams des commandes / livreurs, confirmation d'attribution, changements de statut |

## 6. Exécution

```bash
flutter pub get
flutter run        # login démo : admin@doken.com / Admin1234
flutter analyze    # 0 problème
flutter test       # test pipeline complet
```
