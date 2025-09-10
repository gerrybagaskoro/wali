// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/extension/navigation.dart';
import 'package:wali_app/model/auth/auth_response.dart';
import 'package:wali_app/preference/shared_preference.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _adminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(Endpoint.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final authResponse = UserAuthResponse.fromJson(
          json.decode(response.body),
        );

        // Cek jika user adalah admin (role = 'admin' atau 'rt_rw')
        final isAdmin =
            // authResponse.data.user.email.contains('@rt.') ||
            // authResponse.data.user.email.contains('@rw.') ||
            // authResponse.data.user.email.contains('@admin.') ||
            // authResponse.data.user.email.contains('admin');
            authResponse.data.user.email.contains('@gmail'); // untuk testing

        if (!isAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun ini bukan Pengelola RT/RW')),
          );
          return;
        }

        // Simpan data login
        await authResponse.saveToPreferences();
        await PreferenceHandler.saveIsAdmin(true);

        if (mounted) {
          context.pushReplacementNamed('/admin-dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Masuk gagal: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Ketika tombol back ditekan, langsung ke welcome screen
        // bukan kembali ke login user
        context.pushReplacementNamed('/welcome');
        return false; // Mencegah default back behavior
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Login Admin RT/RW'),
        //   automaticallyImplyLeading: false, // Hilangkan tombol back
        // ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selamat datang kembali!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gunakan akun pengelola yang terdaftar di sistem',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Surel',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Surel harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata Sandi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _adminLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Masuk sebgai Pengelola',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    // Kembali ke welcome screen, bukan login user
                    context.pushReplacementNamed('/login');
                  },
                  child: const Text('Kembali ke Halaman Masuk Warga'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
