import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Login (Email/Pass - optional/legacy)
  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return _handleAuthResponse(response.data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('An unexpected error occurred');
    }
  }

  // Send OTP
  Future<void> sendOtp(String mobile) async {
    try {
      await _apiClient.post(ApiConstants.sendOtp, data: {'phone': mobile});
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String msg = 'Failed to send OTP';
        if (data is Map<String, dynamic>) {
          msg = data['message'] ?? msg;
        } else if (data is String) {
          msg = data;
        }
        throw Exception(msg);
      }
      throw Exception('An unexpected error occurred');
    }
  }

  // Verify OTP (Login)
  Future<User> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {'phone': mobile, 'otp': otp},
      );
      return _handleAuthResponse(response.data);
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String msg = 'Invalid OTP';
        if (data is Map<String, dynamic>) {
          msg = data['message'] ?? msg;
        } else if (data is String) {
          msg = data;
        }
        throw Exception(msg);
      }
      throw Exception('An unexpected error occurred');
    }
  }

  Future<User> _handleAuthResponse(dynamic responseData) async {
    final data = responseData is Map<String, dynamic> ? responseData : {};

    // Check if wrapped in "data" object (common api pattern)
    final payload = data.containsKey('data') ? data['data'] : data;

    final accessToken =
        payload['accessToken'] ?? payload['access_token'] ?? payload['token'];
    final refreshToken = payload['refreshToken'] ?? payload['refresh_token'];
    final userJson = payload['user'];

    if (accessToken != null && accessToken.toString().isNotEmpty) {
      await _saveSession(accessToken, refreshToken ?? '', userJson ?? {});
    } else {
      // If we can't find a token, we must fail the login
      throw Exception(
        "Authentication successful but no access token returned.",
      );
    }

    return User.fromJson(userJson);
  }

  // Register
  Future<User> register(
    String fullName,
    String email,
    String password,
    String mobile,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'mobile': mobile,
        },
      );

      // Assuming register might login automatically or require login
      // If it returns token immediately:
      if (response.data['accessToken'] != null) {
        final data = response.data;
        await _saveSession(
          data['accessToken'],
          data['refreshToken'],
          data['user'],
        );
        return User.fromJson(data['user']);
      } else {
        // If it just creates account
        return User(id: '', fullName: fullName, email: email);
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
  }

  // Get Current User (from local storage)
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null) {
      return User.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  // Check if Logged In
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  // Private: Save Session
  Future<void> _saveSession(
    String access,
    String refresh,
    Map<String, dynamic> user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', access);
    await prefs.setString('refresh_token', refresh);
    await prefs.setString('user_data', jsonEncode(user));
  }
}
