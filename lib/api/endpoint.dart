class Endpoint {
  static const String appName = 'Wali - Warga Peduli';
  static const String baseURL = 'http://applaporan.mobileprojp.com/api';

  // Report Endpoints
  static const String login = '$baseURL/login';
  static const String register = '$baseURL/register';
  static const String laporan = '$baseURL/laporan';
  static const String riwayat = '$baseURL/riwayat';
  static const String statistik = '$baseURL/statistik';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
