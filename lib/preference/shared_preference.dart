// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";
  static const String userDataKey = "user_data"; // Key untuk simpan data user

  // static void saveLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(loginKey, true);
  // }

  // Menyimpan status login dengan nilai boolean
  // Single Responsibility Principle
  static Future<void> saveLogin(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, isLoggedIn);
  }

  // Simpan token
  // static void saveToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(tokenKey, token);
  // }

  // Simpan token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Simpan data user dalam format JSON string
  static Future<void> saveUserData(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, userJson);
  }

  // Get status login - PERBAIKAN: return Future<bool?>
  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  // Get token - PERBAIKAN: return Future<String?>
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get user data - PERBAIKAN: return Future<String?>
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userDataKey);
  }

  // Hapus semua data login
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
    await prefs.remove(tokenKey);
    await prefs.remove(userDataKey);
  }
}
