class ApiConstants {
  static const String baseUrl =
      'https://team1api.empyreal.in/api/v1'; // Verified /api/v1/auth/send-otp returns 200

  // Auth Endpoints
  static const String login = '/auth/login'; // Keep for legacy/admin if needed
  static const String register = '/auth/register';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/profile';

  // Project Endpoints
  static const String projects = '/projects';
  static const String projectStats = '/projects/stats';
  static const String projectPending = '/projects/pending';
  static String projectUpload(String id) => '/projects/$id/upload';
  static String projectPreview(String id) => '/projects/$id/preview';
  static String projectById(String id) => '/projects/$id';
}
