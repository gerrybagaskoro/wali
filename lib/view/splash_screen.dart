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
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await PreferenceHandler.getLogin();
    final token = await PreferenceHandler.getToken();
    final isAdmin = await PreferenceHandler.getIsAdmin() ?? false;

    if (isLoggedIn == true && token != null) {
      if (isAdmin) {
        context.pushReplacementNamed('/admin-dashboard');
      } else {
        context.pushReplacementNamed('/dashboard');
      }
    } else {
      context.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              Endpoint.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
