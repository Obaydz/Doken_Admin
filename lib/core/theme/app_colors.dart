import 'package:flutter/material.dart';

/// ============================================================
///  ADMIN — PALETTE DE COULEURS (SEUL ENDROIT À MODIFIER)
///  Pour changer le style de l'app, modifiez uniquement ce fichier.
/// ============================================================
class AppColors {
  AppColors._();

  // --- Couleur principale : indigo ---
  static const Color primary       = Color(0xFF4F46E5); // indigo-600
  static const Color primaryDark   = Color(0xFF4338CA); // indigo-700
  static const Color primaryLight  = Color(0xFFEEF2FF); // indigo-50
  static const Color primarySoft   = Color(0xFFEEF2FF); // fonds teintés (chips, icônes)
  static const Color onPrimary     = Color(0xFFFFFFFF);

  // --- Fonds et surfaces ---
  static const Color background    = Color(0xFFF8FAFC); // slate-50
  static const Color surface       = Color(0xFFFFFFFF); // cartes, champs
  static const Color surfaceAlt    = Color(0xFFF1F5F9); // zones secondaires
  static const Color border        = Color(0xFFE2E8F0); // slate-200
  static const Color divider       = Color(0xFFF1F5F9); // slate-100

  // --- Textes ---
  static const Color textPrimary   = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color textHint      = Color(0xFF94A3B8); // slate-400
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // --- États : En attente / Ambre ---
  static const Color pending       = Color(0xFFF59E0B);
  static const Color pendingSoft   = Color(0xFFFFFBEB);
  static const Color pendingText   = Color(0xFF92400E);

  // --- États : Confirmée / Bleu ---
  static const Color confirmed     = Color(0xFF3B82F6);
  static const Color confirmedSoft = Color(0xFFEFF6FF);
  static const Color confirmedText = Color(0xFF1E40AF);

  // --- États : En livraison / Violet ---
  static const Color delivering    = Color(0xFF8B5CF6);
  static const Color deliveringSoft= Color(0xFFF5F3FF);
  static const Color deliveringText= Color(0xFF5B21B6);

  // --- États : Livrée / Vert ---
  static const Color success       = Color(0xFF22C55E);
  static const Color successSoft   = Color(0xFFF0FDF4);
  static const Color successText   = Color(0xFF166534);

  // --- États : Annulée / Rouge ---
  static const Color error         = Color(0xFFEF4444);
  static const Color errorSoft     = Color(0xFFFFF5F5);
  static const Color errorText     = Color(0xFF991B1B); // red-800

  // --- Divers ---
  static const Color transparent   = Color(0x00000000);
  static const Color shadow        = Color(0x14000000);
  static const Color overlay       = Color(0x66000000);
  static const Color shimmerBase   = Color(0xFFE2E8F0);
  static const Color shimmerHigh   = Color(0xFFF1F5F9);
  static const Color chartLine     = Color(0xFF4F46E5);

  // --- Étoiles de notation ---
  static const Color star          = Color(0xFFF2B01E);
}
