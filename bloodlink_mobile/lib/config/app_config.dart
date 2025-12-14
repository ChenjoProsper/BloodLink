import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    // 1. Si on est en mode Release (Production sur Vercel)
    if (kReleaseMode && kIsWeb) {
      // 🚀 REMPLACEZ PAR VOTRE URL RENDER
      return 'https://bloodlink-y0ur.onrender.com';
    }

    // 2. Si on est en développement Web (localhost)
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    // 3. Fallback Mobile (Android/iOS)
    else {
      // Pour l'émulateur Android par défaut
      return 'https://bloodlink-y0ur.onrender.com';
    }
  }

  static const String apiVersion = '/api/v1';
  static const String loginEndpoint = '$apiVersion/auth/login';
  static const String registerDonneurEndpoint =
      '$apiVersion/auth/register/donneur';
  static const String registerMedecinEndpoint =
      '$apiVersion/auth/register/medecin';
  static const String alertesEndpoint = '$apiVersion/alertes';
  static const String donneursEndpoint = '$apiVersion/donneurs';
  static const String medecinsEndpoint = '$apiVersion/medecins';
  static const String reponsesEndpoint = '$apiVersion/reponses';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const double alertRadius = 5.0;
}
