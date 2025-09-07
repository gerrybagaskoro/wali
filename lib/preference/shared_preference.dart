// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";
  static const String userDataKey = "user_data";
  static const String isAdminKey = "is_admin";
  static const String onboardingShownKey = "onboarding_shown"; // ✅ SUDAH ADA

  // ✅ TAMBAHKAN METHOD UNTUK ONBOARDING
  // Simpan status onboarding sudah ditampilkan
  static Future<void> saveOnboardingShown(bool shown) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingShownKey, shown);
  }

  // Get status onboarding
  static Future<bool> getOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingShownKey) ??
        false; // Default false (belum ditampilkan)
  }

  // ✅ PERBAIKI METHOD CLEARALL - JANGAN HAPUS ONBOARDING STATUS
  // Hapus semua data login TANPA menghapus onboarding status
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
    await prefs.remove(tokenKey);
    await prefs.remove(userDataKey);
    await prefs.remove(isAdminKey);
    // ✅ JANGAN hapus onboardingShownKey agar tetap ingat sudah pernah ditampilkan
  }

  // ✅ METHOD YANG SUDAH ADA (TIDAK PERLU DIUBAH)
  static Future<void> saveLogin(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, isLoggedIn);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<void> saveUserData(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, userJson);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userDataKey);
  }

  static Future<void> saveIsAdmin(bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isAdminKey, isAdmin);
  }

  static Future<bool?> getIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isAdminKey);
  }

  // ✅ OPSIONAL: Method clear yang menghapus SEMUA termasuk onboarding
  static Future<void> clearAllIncludingOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
    await prefs.remove(tokenKey);
    await prefs.remove(userDataKey);
    await prefs.remove(isAdminKey);
    await prefs.remove(onboardingShownKey); // Hapus juga onboarding status
  }
}
