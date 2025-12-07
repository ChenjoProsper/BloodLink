import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../config/app_config.dart';
import '../models/alerte.dart';

class AlerteProvider with ChangeNotifier {
    final _api = ApiService();

    List<Alerte> _alertes = [];
    bool _isLoading = false;
    String? _errorMessage;

    List<Alerte> get alertes => _alertes;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;

    /// Créer une alerte (Médecin)
    Future<bool> createAlerte(Alerte alerte) async {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        try {
        final response = await _api.post(
            AppConfig.alertesEndpoint,
            data: alerte.toJson(),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
            _isLoading = false;
            notifyListeners();
            return true;
        }

        _errorMessage = 'Erreur lors de la création de l\'alerte';
        _isLoading = false;
        notifyListeners();
        return false;
        } catch (e) {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
        notifyListeners();
        return false;
        }
    }

    /// Récupérer les donneurs recommandés
    Future<List<dynamic>> getRecommendations(double latitude, double longitude) async {
        try {
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
        } catch (e) {
        return [];
        }
    }

    /// Accepter une alerte (Donneur)
    Future<bool> accepterAlerte(String alerteId, String donneurId) async {
        try {
        final response = await _api.post(
            '${AppConfig.reponsesEndpoint}/accepter',
            data: {
            'alerteId': alerteId,
            'donneurId': donneurId,
            },
        );

        return response.statusCode == 201 || response.statusCode == 200;
        } catch (e) {
        return false;
        }
    }

    /// Valider une alerte (Médecin)
    Future<bool> validerAlerte(String reponseId) async {
        try {
        final response = await _api.patch(
            '${AppConfig.reponsesEndpoint}/$reponseId/valider',
        );

        return response.statusCode == 200;
        } catch (e) {
        return false;
        }
    }
}