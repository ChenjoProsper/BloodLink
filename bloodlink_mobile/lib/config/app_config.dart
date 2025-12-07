class AppConfig {
  // URL de votre backend
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8086'; // iOS Simulator
  // static const String baseUrl = 'http://YOUR_IP:8086'; // Appareil physique

    static const String apiVersion = '/api/v1';

  // Endpoints
    static const String loginEndpoint = '$apiVersion/auth/login';
    static const String registerDonneurEndpoint = '$apiVersion/auth/register/donneur';
    static const String registerMedecinEndpoint = '$apiVersion/auth/register/medecin';
    static const String alertesEndpoint = '$apiVersion/alertes';
    static const String donneursEndpoint = '$apiVersion/donneurs';
    static const String medecinsEndpoint = '$apiVersion/medecins';
    static const String reponsesEndpoint = '$apiVersion/reponses';

  // Configuration
    static const int connectionTimeout = 30000; // 30 secondes
    static const int receiveTimeout = 30000;
    static const double alertRadius = 5.0; // km
}