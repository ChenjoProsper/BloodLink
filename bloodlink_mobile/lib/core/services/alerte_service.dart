import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../models/alerte.dart';
import '../../models/reponse.dart'; // NÉCESSAIRE pour getReponsesByMedecinId
import 'api_service.dart';

class AlerteService {
  final _api = ApiService();
  final _logger = Logger();

  /// Créer une alerte (Médecin uniquement)
  Future<Map<String, dynamic>> createAlerte(Alerte alerte) async {
    // ... (Logique existante) ...
    try {
      _logger.i('Création d\'une alerte: ${alerte.description}');
      final response = await _api.post(
        AppConfig.alertesEndpoint,
        data: alerte.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('Alerte créée avec succès');
        return {
          'success': true,
          'alerte': Alerte.fromJson(response.data),
        };
      }
      return {'success': false, 'message': 'Erreur lors de la création'};
    } on DioException catch (e) {
      // ... (Gestion des erreurs) ...
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de la création'
      };
    }
  }

  /// NOUVEAU: Récupérer les alertes par ID de médecin
  Future<List<Alerte>> getAlertesByMedecinId(String medecinId) async {
    try {
      _logger.i('Récupération des alertes pour le médecin: $medecinId');

      final response = await _api.get(
        '${AppConfig.alertesEndpoint}/medecin/$medecinId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Alerte.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      _logger.e('Erreur récupération alertes médecin: ${e.message}');
      return [];
    }
  }

  /// NOUVEAU: Récupérer les réponses reçues par un médecin
  Future<List<Reponse>> getReponsesByMedecinId(String medecinId) async {
    try {
      _logger.i('Récupération des réponses pour le médecin: $medecinId');

      final response = await _api.get(
        '${AppConfig.reponsesEndpoint}/medecin/$medecinId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Assurez-vous d'avoir un constructeur Reponse.fromJson
        return data.map((json) => Reponse.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      _logger.e('Erreur récupération réponses médecin: ${e.message}');
      return [];
    }
  }

  /// Récupérer les donneurs recommandés
  Future<List<dynamic>> getRecommendations(
      double latitude, double longitude) async {
    // ... (Logique existante) ...
    try {
      final response = await _api.get(
        '${AppConfig.alertesEndpoint}/recommandations',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Accepter une alerte (Donneur)
  Future<Map<String, dynamic>> accepterAlerte(
      String alerteId, String donneurId) async {
    // ... (Logique existante) ...
    try {
      final response = await _api.post(
        '${AppConfig.reponsesEndpoint}/accepter',
        data: {
          'alerteId': alerteId,
          'donneurId': donneurId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'donneur': response.data,
        };
      }
      return {'success': false, 'message': 'Erreur lors de l\'acceptation'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur'};
    }
  }

  /// Valider une alerte (Médecin - après le don)
  Future<Map<String, dynamic>> validerAlerte(String reponseId) async {
    // ... (Logique existante) ...
    try {
      final response = await _api.patch(
        '${AppConfig.reponsesEndpoint}/$reponseId/valider',
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data,
        };
      }
      return {'success': false, 'message': 'Erreur validation alerte'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
