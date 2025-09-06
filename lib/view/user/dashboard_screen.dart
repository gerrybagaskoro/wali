// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/model/auth/auth_response.dart' as auth_model;
import 'package:wali_app/model/report/report_list_response.dart'
    as report_model;
import 'package:wali_app/preference/shared_preference.dart';
import 'package:wali_app/view/user/profile_screen.dart';
import 'package:wali_app/view/user/user_add_report.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  auth_model.User? _currentUser;
  List<report_model.Datum> _reports = [];
  bool _isLoading = true;
  bool _showMyReports = true;

  // Variabel untuk pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10; // Tampilkan 10 item per halaman
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _carouselItems = [
    {
      'title': 'Cara Melaporkan',
      'description':
          'Klik + Buat Laporan Baru untuk membuat laporan baru dengan foto dan deskripsi',
      'icon': '📝',
    },
    {
      'title': 'Pantau Status',
      'description':
          'Lihat perkembangan laporan Anda dari status "masuk" hingga "selesai"',
      'icon': '📊',
    },
    {
      'title': 'Kolaborasi Warga',
      'description':
          'Bantu warga lain dengan memberikan informasi dan dukungan',
      'icon': '👥',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReports();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreReports();
    }
  }

  Future<void> _loadMoreReports() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    await _loadReports();
  }

  Future<void> _loadUserData() async {
    final userData = await PreferenceHandler.getUserData();
    if (userData != null && mounted) {
      setState(() {
        _currentUser = auth_model.User.fromJson(json.decode(userData));
      });
    }
  }

  // Future<void> _loadReports() async {
  //   try {
  //     final token = await PreferenceHandler.getToken();
  //     if (token == null) return;

  //     final response = await http.get(
  //       Uri.parse(Endpoint.laporan),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final reportResponse = report_model.ReportListResponse.fromJson(
  //         json.decode(response.body),
  //       );
  //       if (mounted) {
  //         setState(() => _reports = reportResponse.data);
  //       }
  //     }
  //   } catch (e) {
  //     print('Error loading reports: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // UBAH METHOD _loadReports MENJADI:
  Future<void> _loadReports({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) return;

      // TAMBAH PARAMETER PAGINATION DI URL
      final response = await http.get(
        Uri.parse(
          '${Endpoint.laporan}?page=$_currentPage&per_page=$_itemsPerPage',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final reportResponse = report_model.ReportListResponse.fromJson(
          json.decode(response.body),
        );

        if (mounted) {
          setState(() {
            if (isRefresh) {
              _reports = reportResponse.data;
            } else {
              _reports.addAll(reportResponse.data);
            }

            // CEK APAKAH MASIH ADA DATA LAGI
            _hasMoreData = reportResponse.data.length == _itemsPerPage;
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      print('Error loading reports: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      await PreferenceHandler.clearAll();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  List<report_model.Datum> get _filteredReports {
    if (_showMyReports) {
      return _reports
          .where((report) => report.user.id == _currentUser?.id)
          .toList();
    } else {
      return _reports
          .where((report) => report.user.id != _currentUser?.id)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wali - Warga Peduli'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReports),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      // body: Padding(
      //   padding: const EdgeInsets.all(6.0),
      //   child: RefreshIndicator(
      //     onRefresh: _loadReports,
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children: [
      //           _buildHeaderSection(),
      //           const SizedBox(height: 16),
      //           _buildCarouselSection(),
      //           const SizedBox(height: 20),
      //           _buildSwitchMenuSection(),
      //           const SizedBox(height: 16),
      //           _buildReportsSection(),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),

      // UBAH BAGIAN BODY MENJADI:
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadReports(isRefresh: true); // TAMBAH PARAMETER isRefresh
          },
          child: SingleChildScrollView(
            controller: _scrollController, // TAMBAH CONTROLLER
            child: Column(
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 16),
                _buildCarouselSection(),
                const SizedBox(height: 20),
                _buildSwitchMenuSection(),
                const SizedBox(height: 16),
                _buildReportsSection(), // INI SUDAH PAKAI LISTVIEW.BUILDER
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const UserAddReport()),
          );
          if (result == true && mounted) {
            _loadReports();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Laporan Baru',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.eco, size: 40, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser != null
                        ? 'Halo, ${_currentUser!.name}!'
                        : 'Halo, Warga!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Mari jaga lingkungan kita bersama',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: _showLogoutDialog,
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    return SizedBox(
      height: 180, // Beri extra space untuk animasi
      child: CarouselSlider(
        options: CarouselOptions(
          height: 160, // Tinggi konten
          autoPlay: true,
          enlargeCenterPage: true,
          enlargeFactor: 0.2, // Kurangi pembesaran
          viewportFraction: 0.75, // Kurangi lebar viewport
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayCurve: Curves.fastOutSlowIn,
        ),
        items: _carouselItems.map((item) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item['icon']!, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    // Gunakan Flexible untuk text yang panjang
                    child: Text(
                      item['description']!,
                      style: const TextStyle(fontSize: 11, height: 1.3),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchMenuSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Laporan:'),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('Laporan Saya'),
          selected: _showMyReports,
          onSelected: (selected) {
            setState(() => _showMyReports = selected);
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Laporan Warga'),
          selected: !_showMyReports,
          onSelected: (selected) {
            setState(() => _showMyReports = !selected);
          },
        ),
      ],
    );
  }

  Widget _buildReportsSection() {
    if (_isLoading && _reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredReports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _showMyReports
                  ? 'Belum ada laporan dari Anda'
                  : 'Belum ada laporan dari warga',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _filteredReports.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredReports.length) {
          return _buildLoadingIndicator();
        }

        return _buildReportCard(_filteredReports[index]);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return _isLoadingMore
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        : Container();
  }

  Widget _buildReportCard(report_model.Datum report) {
    Color statusColor = Colors.grey;
    if (report.status == 'proses') statusColor = Colors.orange;
    if (report.status == 'selesai') statusColor = Colors.green;

    final isMyReport = report.user.id == _currentUser?.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER - Avatar, Nama, Status
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isMyReport
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  child: Text(
                    report.user.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMyReport ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: report.user.name,
                    child: Text(
                      report.user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    report.status.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // JUDUL
            Text(
              report.judul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // LOKASI - DENGAN OVERFLOW PROTECTION
            if (report.lokasi != null && report.lokasi!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Tooltip(
                      message: report.lokasi!,
                      child: Text(
                        report.lokasi!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // DESKRIPSI
            Text(report.isi, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),

            // GAMBAR
            // if (report.imageUrl != null) ...[
            //   ClipRRect(
            //     borderRadius: BorderRadius.circular(8),
            //     child: Image.network(
            //       report.imageUrl!,
            //       height: 320,
            //       width: double.infinity,
            //       fit: BoxFit.cover,
            //       loadingBuilder: (context, child, loadingProgress) {
            //         if (loadingProgress == null) return child;
            //         return Container(
            //           height: 200,
            //           color: Colors.grey.shade200,
            //           child: Center(
            //             child: CircularProgressIndicator(
            //               value: loadingProgress.expectedTotalBytes != null
            //                   ? loadingProgress.cumulativeBytesLoaded /
            //                         loadingProgress.expectedTotalBytes!
            //                   : null,
            //             ),
            //           ),
            //         );
            //       },
            //       errorBuilder: (context, error, stackTrace) {
            //         return Container(
            //           height: 200,
            //           color: Colors.grey.shade200,
            //           child: const Icon(Icons.error, color: Colors.grey),
            //         );
            //       },
            //     ),
            //   ),
            //   const SizedBox(height: 8),
            // ],
            // DI _buildReportCard, UBAH BAGIAN GAMBAR:
            if (report.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  // GUNAKAN CachedNetworkImage
                  imageUrl: report.imageUrl!,
                  height: 360,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 360,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 360,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // TIMESTAMP
            Text(
              'Dibuat: ${_formatDate(report.createdAt)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
