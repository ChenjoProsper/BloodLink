import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final _logger = Logger();

  /// Vérifie et demande les permissions de localisation
  Future<bool> requestLocationPermission() async {
    // ✅ Sur Web, les permissions sont gérées par le navigateur
    if (kIsWeb) {
      _logger.i('Web: Permissions de localisation gérées par le navigateur');
      return true;
    }
    
    PermissionStatus permission = await Permission.location.status;

    if (permission.isDenied) {
      permission = await Permission.location.request();
    }

    if (permission.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return permission.isGranted;
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<Position?> getCurrentPosition() async {
    try {
      // ✅ Sur Web, vérifier d'abord si la géolocalisation est disponible
      if (kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _logger.w('Web: Service de localisation non disponible');
          return null;
        }
      } else {
        bool hasPermission = await requestLocationPermission();
        if (!hasPermission) {
          _logger.w('Permission de localisation refusée');
          return null;
        }

        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _logger.w('Service de localisation désactivé');
          return null;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _logger.i('Position obtenue: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Erreur lors de la récupération de la position: $e');
      return null;
    }
  }

  /// Écoute les changements de position en temps réel
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  /// Calcule la distance entre deux points (en km)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
