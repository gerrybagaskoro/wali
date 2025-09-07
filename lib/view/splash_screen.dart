// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/extension/navigation.dart';
import 'package:wali_app/preference/shared_preference.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Tunggu 2 detik untuk splash screen
    await Future.delayed(const Duration(seconds: 2));
    await _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      final isLoggedIn = await PreferenceHandler.getLogin();
      final token = await PreferenceHandler.getToken();
      final isOnboardingShown = await PreferenceHandler.getOnboardingShown();

      // Jika sudah login dan token valid
      if (isLoggedIn == true && token != null) {
        await _navigateToDashboard();
      }
      // Jika belum login dan onboarding belum ditampilkan
      else if (!isOnboardingShown) {
        _navigateToWelcome();
      }
      // Jika sudah pernah lihat onboarding
      else {
        _navigateToLogin();
      }
    } catch (e) {
      // Fallback ke login screen jika ada error
      _navigateToLogin();
    }
  }

  Future<void> _navigateToDashboard() async {
    final isAdmin = await PreferenceHandler.getIsAdmin() ?? false;

    if (isAdmin) {
      context.pushReplacementNamed('/admin-dashboard');
    } else {
      context.pushReplacementNamed('/dashboard');
    }
  }

  void _navigateToWelcome() {
    context.pushReplacementNamed('/welcome');
  }

  void _navigateToLogin() {
    context.pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 80, color: Colors.white),
            SizedBox(height: 20),
            _AppNameText(),
            SizedBox(height: 20),
            _LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}

class _AppNameText extends StatelessWidget {
  const _AppNameText();

  @override
  Widget build(BuildContext context) {
    return Text(
      Endpoint.appName,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }
}
