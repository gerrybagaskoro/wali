import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/view/admin/admin_dashboard_screen.dart';
import 'package:wali_app/view/admin/admin_login_screen.dart';
import 'package:wali_app/view/splash_screen.dart';
import 'package:wali_app/view/user/dashboard_screen.dart';
import 'package:wali_app/view/user/login_screen.dart';
import 'package:wali_app/view/user/profile_screen.dart';
import 'package:wali_app/view/user/register_screen.dart';
import 'package:wali_app/view/user/user_add_report.dart';
import 'package:wali_app/view/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Endpoint.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.blue.shade600,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/add-report': (context) => const UserAddReport(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
