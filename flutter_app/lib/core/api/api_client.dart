import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config_service.dart';
import 'dart:io';

class ApiClient {
  late Dio _dio;
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() {
    return _instance;
  }
  
  ApiClient._internal() {
    _initializeDio();
    // Load stored URL asynchronously
    _loadStoredBaseUrl();
  }
  
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfigService.getCurrentBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to requests
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Log connection errors for debugging
        if (error.type == DioExceptionType.connectionTimeout || 
            error.type == DioExceptionType.connectionError) {
          print('Connection Error: ${error.message}');
          print('Trying to connect to: ${_dio.options.baseUrl}');
          print('Make sure the backend server is running');
        }
        
        // Handle 401 - refresh token
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the request
            final opts = error.requestOptions;
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('access_token');
            if (token != null) {
              opts.headers['Authorization'] = 'Bearer $token';
            }
            final response = await _dio.fetch(opts);
            return handler.resolve(response);
          }
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        '/auth/refresh/',
        data: {'refresh': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      
      if (response.statusCode == 200) {
        await prefs.setString('access_token', response.data['access']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Dio get dio => _dio;
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(String path, {dynamic data, Options? options}) {
    return _dio.post(path, data: data, options: options);
  }
  
  Future<Response> put(String path, {dynamic data, Options? options}) {
    return _dio.put(path, data: data, options: options);
  }
  
  Future<Response> patch(String path, {dynamic data, Options? options}) {
    return _dio.patch(path, data: data, options: options);
  }
  
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
  
  /// Update the base URL and reinitialize Dio
  Future<void> updateBaseUrl(String newBaseUrl) async {
    await ApiConfigService.setBaseUrl(newBaseUrl);
    _initializeDio();
  }
  
  /// Get current base URL
  String get baseUrl => _dio.options.baseUrl;
  
  /// Load stored base URL from SharedPreferences
  Future<void> _loadStoredBaseUrl() async {
    try {
      final storedUrl = await ApiConfigService.getBaseUrl();
      if (storedUrl != _dio.options.baseUrl) {
        _dio.options.baseUrl = storedUrl;
      }
    } catch (e) {
      // If loading fails, keep default URL
      print('Failed to load stored base URL: $e');
    }
  }
}

