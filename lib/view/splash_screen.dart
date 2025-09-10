// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wali_app/extension/navigation.dart';
import 'package:wali_app/preference/shared_preference.dart';
import 'package:wali_app/utils/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _showLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animasi fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Tunggu 2 detik sebelum menampilkan animasi loading
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() {
      _showLoading = true;
    });

    // Mulai animasi fade-in
    _fadeController.forward();

    await _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      final isLoggedIn = await PreferenceHandler.getLogin();
      final token = await PreferenceHandler.getToken();
      final isOnboardingShown = await PreferenceHandler.getOnboardingShown();

      if (isLoggedIn == true && token != null) {
        await _navigateToDashboard();
      } else if (!isOnboardingShown) {
        _navigateToWelcome();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
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
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(width: 180, height: 180),
            const SizedBox(height: 20),
            if (_showLoading)
              FadeTransition(
                opacity: _fadeAnimation,
                child: const _LoadingIndicator(),
              ),
          ],
        ),
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
