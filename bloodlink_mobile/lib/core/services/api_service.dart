import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
    static final ApiService _instance = ApiService._internal();
    factory ApiService() => _instance;
    ApiService._internal();

    late Dio _dio;
    final _logger = Logger();
    final _storage = StorageService();

    void init() {
        _dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        },
        ));

        // Intercepteur pour ajouter le token JWT
        _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
            final token = await _storage.getToken();
            if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            }
            _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
            return handler.next(options);
        },
        onResponse: (response, handler) {
            _logger.d('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
            return handler.next(response);
        },
        onError: (error, handler) {
            _logger.e('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
            return handler.next(error);
        },
        ));
    }

    Dio get dio => _dio;

    // Méthodes HTTP génériques
    Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
        try {
        return await _dio.get(path, queryParameters: queryParameters);
        } catch (e) {
        rethrow;
        }
    }

    Future<Response> post(String path, {dynamic data}) async {
        try {
        return await _dio.post(path, data: data);
        } catch (e) {
        rethrow;
        }
    }

    Future<Response> patch(String path, {dynamic data}) async {
        try {
        return await _dio.patch(path, data: data);
        } catch (e) {
        rethrow;
        }
    }

    Future<Response> delete(String path) async {
        try {
        return await _dio.delete(path);
        } catch (e) {
        rethrow;
        }
    }
}