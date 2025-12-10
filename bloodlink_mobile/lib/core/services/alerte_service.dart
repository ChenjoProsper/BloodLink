import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import '../../models/alerte.dart';
import '../../models/reponse.dart';
import '../../models/donneur.dart'; // Import pour le bricolage
import 'api_service.dart';

class AlerteService {
  final _api = ApiService();
  final _logger = Logger();

  /// Récupérer les alertes créées par un médecin par son ID
  Future<List<Alerte>> getAlertesByMedecinId(String medecinId) async {
    if (medecinId.isEmpty) return [];
    try {
      final response =
          await _api.get('${AppConfig.alertesEndpoint}/medecin/$medecinId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Alerte.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.e('Erreur récupération alertes médecin: $e');
      return [];
    }
  }

  /// 🚀 CORRECTION CRASH "À VALIDER" : Reconstruction manuelle des Reponses
  Future<List<Reponse>> getReponsesByMedecinId(String medecinId) async {
    if (medecinId.isEmpty) return [];
    try {
      final response =
          await _api.get('${AppConfig.reponsesEndpoint}/medecin/$medecinId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Mappage manuel pour créer des Reponses valides avec des objets Donneur/Alerte bricolés
        return data.map((json) {
          // 1. Reconstruire le Donneur à partir des champs plats du JSON
          Donneur donneurReconstruit = Donneur(
            // On utilise les champs du JSON plat pour remplir les champs de Donneur.dart
            userId: json['donneurId'] ?? json['userId'] ?? 'unknown',
            email: json['email'] ?? 'Email masqué',
            nom: json['nom'] ?? 'Donneur Inconnu',
            sexe: json['sexe'],
            numero: json['numero'] ?? '',
            role:
                'DONNEUR', // Valeur par défaut obligatoire pour le modèle Donneur
            groupeSanguin: json['gsang'] ?? 'N/A',
            solde: (json['solde'] as num?)?.toDouble() ?? 0.0,
            latitude: (json['latitude'] as num?)?.toDouble(),
            longitude: (json['longitude'] as num?)?.toDouble(),
          );

          // 2. Créer une Alerte "Placeholder" (Le modèle Alerte.dart n'embarque pas le médecin, c'est plus simple)
          Alerte alertePlaceholder = Alerte(
            alerteId: json['alerteId']?.toString() ?? 'unknown',
            description: json['descriptionAlerte'] ??
                'Réponse reçue (Détails non chargés)',
            gsang: json['gsangAlerte'] ?? 'N/A',
            remuneration: (json['remuneration'] as num?)?.toDouble() ?? 0.0,
            medecinId: medecinId, // L'ID du médecin est connu
            etat: 'EN_COURS',
          );

          // 3. Retourner l'objet Reponse propre
          return Reponse(
            reponseId: json['reponseId'] ?? '',
            alerte: alertePlaceholder,
            donneur: donneurReconstruit,
            dateReponse: json['dateReponse'] != null
                ? DateTime.tryParse(json['dateReponse']!) ?? DateTime.now()
                : DateTime.now(),
            statut: json['statut'] ?? 'EN_ATTENTE',
          );
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      _logger.e(
          'Erreur Dio lors de la récupération des réponses pour le médecin: ${e.message}');
      return [];
    } catch (e) {
      _logger.e('Erreur générique réponses: $e');
      return [];
    }
  }

  /// Créer une alerte
  Future<Map<String, dynamic>> createAlerte(Alerte alerte) async {
    try {
      final response = await _api.post(
        AppConfig.alertesEndpoint,
        data: alerte.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'alerte': Alerte.fromJson(response.data),
        };
      }
      return {'success': false, 'message': 'Erreur création'};
    } catch (e) {
      _logger.e('Erreur createAlerte: $e');
      return {'success': false, 'message': 'Erreur'};
    }
  }

  /// Récupérer les alertes actives
  Future<List<Alerte>> getAlertesActives(String gsang) async {
    try {
      final response =
          await _api.get('${AppConfig.alertesEndpoint}/actives/$gsang');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Alerte.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Accepter une alerte
  Future<Map<String, dynamic>> accepterAlerte(
      String alerteId, String donneurId) async {
    try {
      final response = await _api.post(
        '${AppConfig.reponsesEndpoint}/accepter',
        data: {'alerteId': alerteId, 'donneurId': donneurId},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'donneur': response.data};
      }
      return {'success': false, 'message': 'Erreur acceptation'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur'};
    }
  }

  /// Valider une alerte
  Future<Map<String, dynamic>> validerAlerte(String reponseId) async {
    try {
      final response =
          await _api.patch('${AppConfig.reponsesEndpoint}/$reponseId/valider');
      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data};
      }
      return {'success': false, 'message': 'Erreur validation'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur'};
    }
  }

  /// Recommandations GPS
  Future<List<dynamic>> getRecommendations(
      double latitude, double longitude) async {
    try {
      final response = await _api.get(
        '${AppConfig.alertesEndpoint}/recommandations',
        queryParameters: {'latitude': latitude, 'longitude': longitude},
      );
      if (response.statusCode == 200) return response.data as List<dynamic>;
      return [];
    } catch (e) {
      return [];
    }
  }
}
