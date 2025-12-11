import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales (adaptez selon votre Figma)
  static const Color primary = Color(0xFFE74C3C);
  static const Color secondary = Color(0xFF3498DB);
  static const Color accent = Color(0xFF2ECC71);

  // Couleurs de base
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE74C3C);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Colors.white;

  // Groupes sanguins
  static const Map<String, Color> bloodGroupColors = {
    'A_POSITIF': Color(0xFFE74C3C),
    'A_NEGATIF': Color(0xFFC0392B),
    'B_POSITIF': Color(0xFF3498DB),
    'B_NEGATIF': Color(0xFF2980B9),
    'AB_POSITIF': Color(0xFF9B59B6),
    'AB_NEGATIF': Color(0xFF8E44AD),
    'O_POSITIF': Color(0xFF2ECC71),
    'O_NEGATIF': Color(0xFF27AE60),
  };
}
