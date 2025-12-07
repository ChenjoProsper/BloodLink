import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/donneur.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
    final _api = ApiService();
    final _storage = StorageService();

    /// Login
    Future<Map<String, dynamic>> login(String email, String password) async {
        try {
        final response = await _api.post(
            AppConfig.loginEndpoint,
            data: {
            'email': email,
            'password': password,
            },
        );

        if (response.statusCode == 200) {
            final data = response.data;
            await _storage.saveToken(data['token']);
            
            // Sauvegarder les infos utilisateur
            final user = User(
            userId: '', // Sera récupéré via un autre appel si nécessaire
            email: data['email'],
            nom: '',
            role: data['role'],
            );
            await _storage.saveUser(user);

            return {
            'success': true,
            'token': data['token'],
            'role': data['role'],
            'email': data['email'],
            };
        }

        return {'success': false, 'message': 'Erreur de connexion'};
        } on DioException catch (e) {
        return {
            'success': false,
            'message': e.response?.data['message'] ?? 'Erreur de connexion'
        };
        }
    }

    /// Register Donneur
    Future<Map<String, dynamic>> registerDonneur({
        required String email,
        required String password,
        required String nom,
        String? sexe,
        required String groupeSanguin,
        double? latitude,
        double? longitude,
        String? numero,
    }) async {
        try {
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
            await _storage.saveToken(data['token']);

            return {
            'success': true,
            'token': data['token'],
            'message': data['message'],
            };
        }

        return {'success': false, 'message': 'Erreur d\'inscription'};
        } on DioException catch (e) {
        return {
            'success': false,
            'message': e.response?.data['message'] ?? 'Erreur d\'inscription'
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

            return {
            'success': true,
            'token': data['token'],
            'message': data['message'],
            };
        }

        return {'success': false, 'message': 'Erreur d\'inscription'};
        } on DioException catch (e) {
        return {
            'success': false,
            'message': e.response?.data['message'] ?? 'Erreur d\'inscription'
        };
        }
    }

    /// Logout
    Future<void> logout() async {
        await _storage.clearUser();
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