// GANTI code di profile_screen.dart dengan ini:

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wali_app/extension/navigation.dart';
import 'package:wali_app/model/report/report_list_response.dart';
import 'package:wali_app/preference/shared_preference.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Cara 1: Gunakan extension jika sudah ditambahkan
    // final user = await UserAuthResponse.getSavedUser();

    // Cara 2: Alternatif langsung pakai PreferenceHandler
    final userData = await PreferenceHandler.getUserData();
    if (userData != null) {
      setState(() {
        _user = User.fromJson(json.decode(userData));
      });
    }
  }

  Future<void> _logout() async {
    // Cara 1: Gunakan extension jika sudah ditambahkan
    // await UserAuthResponse.logout();

    // Cara 2: Alternatif langsung pakai PreferenceHandler
    await PreferenceHandler.clearAll();

    if (mounted) {
      context.pushNamedAndRemoveAll('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      _user!.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _user!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _user!.email,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  _buildInfoItem(
                    'Bergabung Sejak',
                    _formatDate(_user!.createdAt),
                  ),
                  _buildInfoItem(
                    'Terakhir Update',
                    _formatDate(_user!.updatedAt),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'LOGOUT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
