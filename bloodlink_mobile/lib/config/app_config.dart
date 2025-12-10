import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // ✅ URL adaptative selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      // Pour Web, utiliser localhost directement
      return 'http://localhost:8000';
    } else {
      // Pour Android Emulator
      return 'http://192.168.13.74:8000';
      // Pour appareil physique, décommentez et mettez votre IP :
      // return '192.168.211.74:8000';
    }
  }

  static const String apiVersion = '/api/v1';

  // Endpoints
  static const String loginEndpoint = '$apiVersion/auth/login';
  static const String registerDonneurEndpoint =
      '$apiVersion/auth/register/donneur';
  static const String registerMedecinEndpoint =
      '$apiVersion/auth/register/medecin';
  static const String alertesEndpoint = '$apiVersion/alertes';
  static const String donneursEndpoint = '$apiVersion/donneurs';
  static const String medecinsEndpoint = '$apiVersion/medecins';
  static const String reponsesEndpoint = '$apiVersion/reponses';

  // Configuration
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const double alertRadius = 5.0;
}
