import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Charte graphique (aplats nets) ──
  static const Color primary = Color(0xFFE79724); // Ambre  RVB 231,151,36
  static const Color secondary = Color(0xFFD9250A); // Rouge  RVB 217,37,10

  // ── Variantes dérivées (hors charte, pour dégradés/états pressés) ──
  static const Color primaryDark = Color(0xFFB8761A);
  static const Color primaryLight = Color(0xFFF2C179);
  static const Color secondaryDark = Color(0xFFA81C07);
  static const Color secondaryLight = Color(0xFFF08A78);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF2B2B2B);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFBDBDBD);
  static const Color textMuted = Color(0xFF5F5F5F);
  static const Color accentText =
      secondary; // texte coloré lisible sur fond clair
  static const Color error = Color(0xFFB00020);

  static const Color textOnDark = white;
  static const Color textOnDarkMuted = Color(0xCCFFFFFF); // blanc 80 %
  static const Color overlayTop = Color(0x66000000); // noir 40 %
  static const Color overlayBottom = Color(0xE6000000); // noir 90 %

  // ── Dégradé des boutons principaux (Ambre → Rouge) ──
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
    stops: [0.0, 0.75], // le rouge arrive plus tôt → texte blanc plus lisible
  );
}
