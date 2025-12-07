import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../models/medecin.dart';
import 'api_service.dart';

class MedecinService {
  final _api = ApiService();
  final _logger = Logger();

  /// Récupérer les coordonnées d'un médecin par son ID
  Future<Map<String, double>?> getCoordonnesByMedecinId(
      String medecinId) async {
    try {
      final response = await _api.get(
        '${AppConfig.medecinsEndpoint}/$medecinId/coordonnees',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'latitude': data['latitude'],
          'longitude': data['longitude'],
        };
      }

      return null;
    } on DioException catch (e) {
      _logger.e('Erreur coordonnées médecin: ${e.message}');
      return null;
    }
  }

  /// Récupérer les coordonnées d'une adresse
  Future<Map<String, double>?> getCoordonnesByAdresse(String adresse) async {
    try {
      final response = await _api.get(
        '${AppConfig.medecinsEndpoint}/coordonnees',
        queryParameters: {'adresse': adresse},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'latitude': data['latitude'],
          'longitude': data['longitude'],
        };
      }

      return null;
    } on DioException catch (e) {
      _logger.e('Erreur coordonnées adresse: ${e.message}');
      return null;
    }
  }

  /// Liste de tous les médecins
  Future<List<Medecin>> getAllMedecins() async {
    try {
      final response = await _api.get(AppConfig.medecinsEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Medecin.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      _logger.e('Erreur récupération médecins: ${e.message}');
      return [];
    }
  }
}
