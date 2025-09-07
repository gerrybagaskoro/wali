// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wali_app/extension/navigation.dart';
import 'package:wali_app/preference/shared_preference.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Selamat Datang di Wali',
      'description': 'Aplikasi untuk warga peduli lingkungan RT/RW',
      'image': '🌱',
    },
    {
      'title': 'Laporkan Masalah',
      'description':
          'Laporkan masalah kebersihan dan fasilitas umum di sekitar Anda',
      'image': '📝',
    },
    {
      'title': 'Pantau Status',
      'description': 'Pantau status laporan Anda secara transparan',
      'image': '📊',
    },
  ];

  Future<void> _markOnboardingAsShown() async {
    await PreferenceHandler.saveOnboardingShown(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _buildOnboardingPage(_onboardingData[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                const SizedBox(height: 20),
                _currentPage == _onboardingData.length - 1
                    ? ElevatedButton(
                        onPressed: () async {
                          // Simpan status bahwa onboarding sudah ditampilkan
                          await _markOnboardingAsShown();
                          context.pushReplacementNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'MULAI SEKARANG',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              // Simpan status bahwa onboarding sudah ditampilkan
                              await _markOnboardingAsShown();
                              context.pushReplacementNamed('/login');
                            },
                            child: const Text('Lewati'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            child: const Text('Lanjut'),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(data['image']!, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 40),
          Text(
            data['title']!,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            data['description']!,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _onboardingData.length; i++) {
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i ? Colors.green : Colors.grey,
          ),
        ),
      );
    }
    return indicators;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
