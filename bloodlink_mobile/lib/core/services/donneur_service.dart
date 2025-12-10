import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../models/donneur.dart';
import 'api_service.dart';

class DonneurService {
  final _api = ApiService();
  final _logger = Logger();

  /// Mettre à jour la position du donneur
  Future<Map<String, dynamic>> updatePosition(
    String donneurId,
    double latitude,
    double longitude,
  ) async {
    try {
      _logger.i('MAJ position donneur: $donneurId');

      // 🚀 CORRECTION : On injecte les paramètres directement dans l'URL
      final url =
          '${AppConfig.donneursEndpoint}/$donneurId/position?latitude=$latitude&longitude=$longitude';

      final response = await _api.patch(url);

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

  /// Liste de tous les donneurs
  Future<List<Donneur>> getAllDonneurs() async {
    try {
      final response = await _api.get(AppConfig.donneursEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Donneur.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Erreur récupération donneurs: ${e.message}');
      return [];
    }
  }

  /// Mettre à jour le FCM token
  Future<void> updateFcmToken(String donneurId, String fcmToken) async {
    try {
      await _api.patch(
        '${AppConfig.donneursEndpoint}/$donneurId/fcm-token',
        data: {'fcmToken': fcmToken},
      );
      _logger.i('✅ FCM token envoyé au backend');
    } catch (e) {
      _logger.e('❌ Erreur envoi FCM token: $e');
    }
  }
}
