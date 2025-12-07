import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';
import '../core/services/api_service.dart';
import '../config/app_config.dart';

class LocationProvider with ChangeNotifier {
    final _locationService = LocationService();
    final _api = ApiService();

    Position? _currentPosition;
    bool _isLoading = false;

    Position? get currentPosition => _currentPosition;
    bool get isLoading => _isLoading;

    /// Obtenir la position actuelle
    Future<void> getCurrentPosition() async {
        _isLoading = true;
        notifyListeners();

        _currentPosition = await _locationService.getCurrentPosition();

        _isLoading = false;
        notifyListeners();
    }

    /// Mettre à jour la position du donneur dans le backend
    Future<bool> updateDonneurPosition(String donneurId) async {
        if (_currentPosition == null) {
        await getCurrentPosition();
        }

        if (_currentPosition == null) return false;

        try {
        final response = await _api.patch(
            '${AppConfig.donneursEndpoint}/$donneurId/position',
            data: {
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
            },
        );

        return response.statusCode == 200;
        } catch (e) {
        return false;
        }
    }

    /// Calculer la distance jusqu'à une alerte
    double? calculateDistanceToAlerte(double alerteLat, double alerteLon) {
        if (_currentPosition == null) return null;

        return _locationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        alerteLat,
        alerteLon,
        );
    }
}