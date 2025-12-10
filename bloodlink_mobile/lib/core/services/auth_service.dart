import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final _api = ApiService();
  final _storage = StorageService();
  final _logger = Logger();

  /// Login avec gestion d'erreurs complète
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      _logger.i('Tentative de connexion: $email');

      final response = await _api.post(
        AppConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Sauvegarder le token
        await _storage.saveToken(data['token']);

        // Sauvegarder les infos utilisateur
        final user = User(
          userId: data['userId'] ?? '',
          email: data['email'],
          nom: data['nom'] ?? '',
          role: data['role'],
        );
        await _storage.saveUser(user);

        _logger.i('Connexion réussie: ${data['role']}');

        return {
          'success': true,
          'token': data['token'],
          'role': data['role'],
          'userId': data['userId'],
          'email': data['email'],
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': 'Erreur de connexion (${response.statusCode})'
      };
    } on DioException catch (e) {
      _logger.e('Erreur Dio: ${e.response?.statusCode} - ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message': 'Délai de connexion dépassé. Vérifiez votre connexion.'
        };
      }

      if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message':
              'Impossible de se connecter au serveur. Vérifiez que le backend est démarré.'
        };
      }

      if (e.response?.statusCode == 401) {
        return {'success': false, 'message': 'Email ou mot de passe incorrect'};
      }

      return {
        'success': false,
        'message':
            e.response?.data['message'] ?? 'Erreur de connexion au serveur'
      };
    } catch (e) {
      _logger.e('Erreur inattendue: $e');
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}'
      };
    }
  }

  /// Register Donneur avec gestion de la position
  Future<Map<String, dynamic>> registerDonneur({
    required String email,
    required String password,
    required String nom,
    String? sexe,
    required String groupeSanguin,
    required double latitude, // OBLIGATOIRE
    required double longitude, // OBLIGATOIRE
    String? numero,
  }) async {
    try {
      _logger.i('Inscription donneur: $email');

      final response = await _api.post(
        AppConfig.registerDonneurEndpoint,
        data: {
          'email': email,
          'password': password,
          'nom': nom,
          'sexe': sexe,
          'gsang': groupeSanguin,
          'latitude': latitude,
          'longitude': longitude,
          'numero': numero,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        // Sauvegarder le token
        await _storage.saveToken(data['token']);

        // Sauvegarder l'utilisateur
        final user = User(
          userId: data['userId'] ?? '',
          email: data['email'],
          nom: nom,
          role: data['role'],
        );
        await _storage.saveUser(user);

        _logger.i('Inscription réussie');

        return {
          'success': true,
          'token': data['token'],
          'message': data['message'],
        };
      }

      return {'success': false, 'message': 'Erreur d\'inscription'};
    } on DioException catch (e) {
      _logger.e('Erreur inscription: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Impossible de se connecter au serveur'
        };
      }

      if (e.response?.statusCode == 409) {
        return {'success': false, 'message': 'Cet email est déjà utilisé'};
      }

      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur d\'inscription'
      };
    } catch (e) {
      _logger.e('Erreur inattendue: $e');
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}'
      };
    }
  }

  /// Register Médecin
  Future<Map<String, dynamic>> registerMedecin({
    required String email,
    required String password,
    required String nom,
    String? sexe,
    required String adresse,
    String? numero,
  }) async {
    try {
      _logger.i('Inscription médecin: $email');

      final response = await _api.post(
        AppConfig.registerMedecinEndpoint,
        data: {
          'email': email,
          'password': password,
          'nom': nom,
          'sexe': sexe,
          'adresse': adresse,
          'numero': numero,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        await _storage.saveToken(data['token']);

        final user = User(
          userId: data['userId'] ?? '',
          email: data['email'],
          nom: nom,
          role: data['role'],
        );
        await _storage.saveUser(user);

        _logger.i('Inscription médecin réussie');

        return {
          'success': true,
          'token': data['token'],
          'message': data['message'],
        };
      }

      return {'success': false, 'message': 'Erreur d\'inscription'};
    } on DioException catch (e) {
      _logger.e('Erreur inscription médecin: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Impossible de se connecter au serveur'
        };
      }

      if (e.response?.statusCode == 409) {
        return {'success': false, 'message': 'Cet email est déjà utilisé'};
      }

      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur d\'inscription'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}'
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storage.clearUser();
    _logger.i('Déconnexion réussie');
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  /// Récupère le rôle de l'utilisateur
  String? getUserRole() {
    final user = _storage.getUser();
    return user?.role;
  }
}
