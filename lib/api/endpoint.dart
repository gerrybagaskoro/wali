class Endpoint {
  static const String appName = 'Wali - Warga Peduli';
  static const String baseURL = 'http://applaporan.mobileprojp.com';

  // Auth Endpoints
  static const String login = '$baseURL/api/login';
  static const String register = '$baseURL/api/register';

  // Report Endpoints
  static const String laporan = '$baseURL/api/laporan';
  static const String riwayat = '$baseURL/api/riwayat';
  static const String statistik = '$baseURL/api/statistik';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
