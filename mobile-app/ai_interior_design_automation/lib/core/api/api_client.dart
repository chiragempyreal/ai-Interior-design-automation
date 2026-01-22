import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

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

    // Add Auth Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token for auth endpoints
          if (!options.path.startsWith('/auth/login') &&
              !options.path.startsWith('/auth/register') &&
              !options.path.startsWith('/auth/forgot-password')) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');

            if (token != null && token.isNotEmpty) {
              debugPrint(
                "ApiClient: Attaching Bearer Token (${token.length} chars)",
              );
              options.headers['Authorization'] = 'Bearer $token';
            } else {
              debugPrint("ApiClient: No token found in SharedPreferences");
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Handle token expiry -> Clear session
            debugPrint("UNAUTHORIZED [401]: Clearing session...");
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear(); // Force logout on next app restart or check
          }
          return handler.next(e);
        },
      ),
    );

    // Log interceptor for debug
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }
}
