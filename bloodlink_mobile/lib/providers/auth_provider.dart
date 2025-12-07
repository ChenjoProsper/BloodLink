import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
    final _authService = AuthService();
    final _storage = StorageService();

    User? _currentUser;
    bool _isLoading = false;
    String? _errorMessage;

    User? get currentUser => _currentUser;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;
    bool get isAuthenticated => _currentUser != null;

    /// Initialise le provider
    Future<void> initialize() async {
        _currentUser = _storage.getUser();
        notifyListeners();
    }

    /// Login
    Future<bool> login(String email, String password) async {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        try {
        final result = await _authService.login(email, password);

        if (result['success']) {
            _currentUser = User(
            userId: '',
            email: result['email'],
            nom: '',
            role: result['role'],
            );
            _isLoading = false;
            notifyListeners();
            return true;
        } else {
            _errorMessage = result['message'];
            _isLoading = false;
            notifyListeners();
            return false;
        }
        } catch (e) {
        _errorMessage = 'Erreur de connexion';
        _isLoading = false;
        notifyListeners();
        return false;
        }
    }

    /// Register Donneur
    Future<bool> registerDonneur({
        required String email,
        required String password,
        required String nom,
        String? sexe,
        required String groupeSanguin,
        double? latitude,
        double? longitude,
        String? numero,
    }) async {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        try {
        final result = await _authService.registerDonneur(
            email: email,
            password: password,
            nom: nom,
            sexe: sexe,
            groupeSanguin: groupeSanguin,
            latitude: latitude,
            longitude: longitude,
            numero: numero,
        );

        if (result['success']) {
            _currentUser = User(
            userId: '',
            email: email,
            nom: nom,
            role: 'DONNEUR',
            );
            _isLoading = false;
            notifyListeners();
            return true;
        } else {
            _errorMessage = result['message'];
            _isLoading = false;
            notifyListeners();
            return false;
        }
        } catch (e) {
        _errorMessage = 'Erreur d\'inscription';
        _isLoading = false;
        notifyListeners();
        return false;
        }
    }

    /// Register Médecin
    Future<bool> registerMedecin({
        required String email,
        required String password,
        required String nom,
        String? sexe,
        required String adresse,
        String? numero,
    }) async {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        try {
        final result = await _authService.registerMedecin(
            email: email,
            password: password,
            nom: nom,
            sexe: sexe,
            adresse: adresse,
            numero: numero,
        );

        if (result['success']) {
            _currentUser = User(
            userId: '',
            email: email,
            nom: nom,
            role: 'MEDECIN',
            );
            _isLoading = false;
            notifyListeners();
            return true;
        } else {
            _errorMessage = result['message'];
            _isLoading = false;
            notifyListeners();
            return false;
        }
        } catch (e) {
        _errorMessage = 'Erreur d\'inscription';
        _isLoading = false;
        notifyListeners();
        return false;
        }
    }

    /// Logout
    Future<void> logout() async {
        await _authService.logout();
        _currentUser = null;
        notifyListeners();
    }
}