import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../models/donneur.dart';
import 'api_service.dart';
import 'location_service.dart'; // NOUVEAU

class DonneurService {
  final _api = ApiService();
  final _logger = Logger();
  final _locationService = LocationService(); // NOUVEAU: Instanciation

  /// Ancienne méthode publique (renommée en interne pour clarté)
  Future<Map<String, dynamic>> _updatePositionApi(
    String donneurId,
    double latitude,
    double longitude,
  ) async {
    try {
      _logger.i('MAJ position donneur: $donneurId (API CALL)');

      final response = await _api.patch(
        '${AppConfig.donneursEndpoint}/$donneurId/position',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data,
        };
      }

      return {'success': false, 'message': 'Erreur MAJ position'};
    } on DioException catch (e) {
      _logger.e('Erreur MAJ position: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erreur'
      };
    }
  }

  /// NOUVEAU: Récupère la position via GPS et la met à jour via l'API
  Future<Map<String, dynamic>> updateDonneurCurrentPosition(
      String donneurId) async {
    final position = await _locationService.getCurrentPosition();

    if (position == null) {
      return {
        'success': false,
        'message':
            'Impossible de récupérer la position. Vérifiez le GPS et les permissions.',
      };
    }

    // Appel à la méthode API interne avec les coordonnées obtenues
    return await _updatePositionApi(
      donneurId,
      position.latitude,
      position.longitude,
    );
  }

  /// Liste de tous les donneurs
  Future<List<Donneur>> getAllDonneurs() async {
    // ... (Logique existante) ...
    try {
      final response = await _api.get(AppConfig.donneursEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Donneur.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Mettre à jour le FCM token
  Future<void> updateFcmToken(String donneurId, String fcmToken) async {
    // ... (Logique existante) ...
    try {
      await _api.patch(
        '${AppConfig.donneursEndpoint}/$donneurId/fcm-token',
        data: {'fcmToken': fcmToken},
      );
    } catch (e) {
      // Erreur gérée
    }
  }
}
