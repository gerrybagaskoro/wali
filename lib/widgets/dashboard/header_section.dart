import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:wali_app/model/auth/auth_response.dart' as auth_model;
import 'package:wali_app/view/user/profile_screen.dart';

class HeaderSection extends StatelessWidget {
  final auth_model.User? currentUser;

  const HeaderSection({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    currentUser != null && currentUser!.name.isNotEmpty
                        ? currentUser!.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser != null
                            ? 'Halo, ${currentUser!.name}!'
                            : 'Halo, Warga!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'Mari jaga lingkungan kita bersama!',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
