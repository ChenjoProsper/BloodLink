import 'package:flutter/material.dart';
import '../core/services/alerte_service.dart';
import '../models/alerte.dart';

class AlerteProvider with ChangeNotifier {
  final _alerteService = AlerteService();

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
      final result = await _alerteService.createAlerte(alerte);

      _isLoading = false;

      if (result['success']) {
        // Ajouter l'alerte créée à la liste
        _alertes.add(result['alerte']);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Récupérer les donneurs recommandés
  Future<List<dynamic>> getRecommendations(
      double latitude, double longitude) async {
    try {
      return await _alerteService.getRecommendations(latitude, longitude);
    } catch (e) {
      return [];
    }
  }

  /// Accepter une alerte (Donneur)
  Future<Map<String, dynamic>> accepterAlerte(
      String alerteId, String donneurId) async {
    try {
      return await _alerteService.accepterAlerte(alerteId, donneurId);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Valider une alerte (Médecin)
  Future<Map<String, dynamic>> validerAlerte(String reponseId) async {
    try {
      return await _alerteService.validerAlerte(reponseId);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Rafraîchir la liste des alertes
  void clearAlertes() {
    _alertes = [];
    notifyListeners();
  }
}
