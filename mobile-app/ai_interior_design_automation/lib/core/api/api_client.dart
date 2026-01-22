import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 🔐 Auth Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth for login/register
          if (!options.path.contains('/auth')) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              debugPrint("✅ Token Attached");
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            debugPrint("❌ 401 Unauthorized — Clearing session");
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
          }
          return handler.next(e);
        },
      ),
    );

    // 📦 Debug Logger
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  // ==============================
  // HTTP METHODS
  // ==============================

  /// GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.get(path, queryParameters: queryParameters);
  }

  /// POST
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return dio.post(path, data: data, options: options);
  }

  /// PUT
  Future<Response> put(String path, {dynamic data}) async {
    return dio.put(path, data: data);
  }

  /// DELETE
  Future<Response> delete(String path) async {
    return dio.delete(path);
  }
}
