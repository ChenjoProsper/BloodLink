import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';

class StorageService {
    static final StorageService _instance = StorageService._internal();
    factory StorageService() => _instance;
    StorageService._internal();

    final _secureStorage = const FlutterSecureStorage();
    late SharedPreferences _prefs;

    Future<void> init() async {
        _prefs = await SharedPreferences.getInstance();
    }

    // Token JWT
    Future<void> saveToken(String token) async {
        await _secureStorage.write(key: 'jwt_token', value: token);
    }

    Future<String?> getToken() async {
        return await _secureStorage.read(key: 'jwt_token');
    }

    Future<void> deleteToken() async {
        await _secureStorage.delete(key: 'jwt_token');
    }

    // User
    Future<void> saveUser(User user) async {
        await _prefs.setString('user', jsonEncode(user.toJson()));
    }

    User? getUser() {
        final userJson = _prefs.getString('user');
        if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
        }
        return null;
    }

    Future<void> clearUser() async {
        await _prefs.remove('user');
        await deleteToken();
    }

    // Autres
    Future<void> saveBool(String key, bool value) async {
        await _prefs.setBool(key, value);
    }

    bool? getBool(String key) {
        return _prefs.getBool(key);
    }
}