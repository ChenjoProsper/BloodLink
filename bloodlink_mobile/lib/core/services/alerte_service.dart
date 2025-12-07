import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../models/alerte.dart';
import '../../models/user.dart';
import 'api_service.dart';

class AlerteService {
  final _api = ApiService();
  final _logger = Logger();

  /// Créer une alerte (Médecin uniquement)
  Future<Map<String, dynamic>> createAlerte(Alerte alerte) async {
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
      _logger.e('Erreur création alerte: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Impossible de se connecter au serveur'
        };
      }

      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur lors de la création'
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur: ${e.toString()}'};
    }
  }

  /// Récupérer les donneurs recommandés (dans un rayon de 5km)
  Future<List<dynamic>> getRecommendations(
      double latitude, double longitude) async {
    try {
      _logger.i('Récupération des recommandations');

      final response = await _api.get(
        '${AppConfig.alertesEndpoint}/recommandations',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }

      return [];
    } on DioException catch (e) {
      _logger.e('Erreur recommandations: ${e.message}');
      return [];
    }
  }

  /// Accepter une alerte (Donneur)
  Future<Map<String, dynamic>> accepterAlerte(
      String alerteId, String donneurId) async {
    try {
      _logger.i('Acceptation alerte: $alerteId');

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
    } on DioException catch (e) {
      _logger.e('Erreur acceptation: ${e.response?.data}');

      if (e.response?.statusCode == 409) {
        return {
          'success': false,
          'message': 'Cette demande n\'est plus disponible'
        };
      }

      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur'
      };
    }
  }

  /// Valider une alerte (Médecin - après le don)
  Future<Map<String, dynamic>> validerAlerte(String reponseId) async {
    try {
      _logger.i('Validation alerte: $reponseId');

      final response = await _api.patch(
        '${AppConfig.reponsesEndpoint}/$reponseId/valider',
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data,
        };
      }

      return {'success': false, 'message': 'Erreur lors de la validation'};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur'
      };
    }
  }
}
