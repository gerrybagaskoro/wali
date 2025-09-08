// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/model/auth/auth_response.dart' as auth_model;
import 'package:wali_app/model/report/report_list_response.dart'
    as report_model;
import 'package:wali_app/preference/shared_preference.dart';
import 'package:wali_app/utils/date_utils.dart';
import 'package:wali_app/view/user/profile_screen.dart';
import 'package:wali_app/view/user/user_add_report.dart';
import 'package:wali_app/view/user/user_detail_report.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _itemsPerPage = 10;

  Future<Map<String, dynamic>>? _dashboardFuture;
  auth_model.User? _currentUser;
  bool _showMyReports = true;

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
    initializeDateFormatting('id_ID', null);
    _scrollController.addListener(_onScroll);
    _loadDashboardData();
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

  void _loadDashboardData() {
    setState(() {
      _dashboardFuture = _fetchDashboardData();
    });
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception('Token tidak valid');

      // ✅ PERBAIKAN: Load data secara terpisah untuk avoid type issues
      final userData = await _loadUserData();
      final reportsData = await _loadReports(token, page: 1);

      return {
        'user': userData,
        'reports': reportsData?['reports'] ?? <report_model.Datum>[],
        'hasMore': reportsData?['hasMore'] ?? false,
        'currentPage': 1,
      };
    } catch (e) {
      throw Exception('Gagal memuat dashboard: $e');
    }
  }

  Future<auth_model.User?> _loadUserData() async {
    try {
      final userData = await PreferenceHandler.getUserData();
      if (userData != null) {
        _currentUser = auth_model.User.fromJson(json.decode(userData));
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadReports(
    String token, {
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.laporan}?page=$page&per_page=$_itemsPerPage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final reportResponse = report_model.ReportListResponse.fromJson(
          json.decode(response.body),
        );

        return {
          'reports': reportResponse.data,
          'hasMore': reportResponse.data.length == _itemsPerPage,
        };
      } else {
        print('HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error loading reports: $e');
      return null;
    }
  }

  Future<void> _loadMoreReports() async {
    try {
      final currentData = await _dashboardFuture;
      if (currentData == null || !(currentData['hasMore'] as bool)) return;

      final token = await PreferenceHandler.getToken();
      if (token == null) return;

      final nextPage = (currentData['currentPage'] as int) + 1;
      final newReportsData = await _loadReports(token, page: nextPage);

      if (newReportsData == null || newReportsData['reports'].isEmpty) return;

      final currentReports = currentData['reports'] as List<report_model.Datum>;
      final newReports = newReportsData['reports'] as List<report_model.Datum>;

      setState(() {
        _dashboardFuture = Future.value({
          'user': currentData['user'],
          'reports': [...currentReports, ...newReports],
          'hasMore': newReportsData['hasMore'] ?? false,
          'currentPage': nextPage,
        });
      });
    } catch (e) {
      print('Error loading more reports: $e');
    }
  }

  Future<void> _handleRefresh() async {
    _loadDashboardData();
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
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
      ),
    );

    if (shouldLogout == true && mounted) {
      await PreferenceHandler.clearAll();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  List<report_model.Datum> _getFilteredReports(
    List<report_model.Datum> reports,
  ) {
    if (_showMyReports) {
      return reports
          .where((report) => report.user.id == _currentUser?.id)
          .toList();
    } else {
      return reports
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            tooltip: 'Profil',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          if (snapshot.hasData) {
            final data = snapshot.data!;
            final reports = data['reports'] as List<report_model.Datum>? ?? [];
            final hasMore = data['hasMore'] as bool? ?? false;
            final filteredReports = _getFilteredReports(reports);

            return _buildSuccessState(filteredReports, hasMore);
          }

          return const Center(child: Text('Tidak ada data'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const UserAddReport()),
          );
          if (result == true && mounted) {
            _loadDashboardData();
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

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(List<report_model.Datum> reports, bool hasMore) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderSection()),
          SliverToBoxAdapter(child: _buildCarouselSection()),
          SliverToBoxAdapter(child: _buildSwitchMenuSection()),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          _buildReportsSection(reports, hasMore),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Bounce(
                infinite: false,
                child: const Icon(Icons.eco, size: 40, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: Text(
                        _currentUser != null
                            ? 'Halo, ${_currentUser!.name}!'
                            : 'Halo, Warga!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: const Text(
                        'Mari jaga lingkungan kita bersama',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              FadeInDown(
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: _showLogoutConfirmation,
                  tooltip: 'Keluar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    return SizedBox(
      height: 180,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 160,
          autoPlay: true,
          enlargeCenterPage: true,
          enlargeFactor: 0.25,
          viewportFraction: 0.75,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayCurve: Curves.fastOutSlowIn,
        ),
        items: _carouselItems.map((item) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
      ),
    );
  }

  Widget _buildReportsSection(List<report_model.Datum> reports, bool hasMore) {
    if (reports.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == reports.length) {
          return hasMore ? _buildLoadingIndicator() : const SizedBox();
        }

        return FadeInDown(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: _buildReportCard(reports[index]),
        );
      }, childCount: reports.length + (hasMore ? 1 : 0)),
    );
  }

  Widget _buildEmptyState() {
    return BounceInDown(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pulse(
              infinite: true,
              child: Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              child: Text(
                _showMyReports
                    ? 'Belum ada laporan dari Anda'
                    : 'Belum ada laporan dari warga',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SpinPerfect(
      infinite: true,
      duration: const Duration(seconds: 1),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildReportCard(report_model.Datum report) {
    final statusColor = _getStatusColor(report.status);
    final isMyReport = report.user.id == _currentUser?.id;

    return ElasticIn(
      duration: const Duration(milliseconds: 600),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DetailLaporanScreen(
                    laporanId: report.id,
                    isMyReport: isMyReport,
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.green.withOpacity(0.2),
        highlightColor: Colors.green.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportHeader(report, statusColor, isMyReport),
                  const SizedBox(height: 8),
                  _buildReportContent(report),
                  if (report.imageUrl != null) _buildReportImage(report),
                  _buildReportFooter(report),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeader(
    report_model.Datum report,
    Color statusColor,
    bool isMyReport,
  ) {
    return Row(
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
          child: Text(
            report.user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Chip(
          label: Text(
            report.status.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: statusColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        ),
      ],
    );
  }

  Widget _buildReportContent(report_model.Datum report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.judul,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (report.lokasi != null) ...[
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.lokasi!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(report.isi, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReportImage(report_model.Datum report) {
    return Column(
      children: [
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(report.imageUrl!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReportFooter(report_model.Datum report) {
    return Text(
      'Dilaporkan: ${_formatDate(report.createdAt)}',
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'proses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final utcDate = DateTime.parse(dateString).toUtc(); // pastikan UTC
      final localDate = utcDate.toLocal(); // convert ke lokal device
      return IndonesianDateUtils.formatDateTime(localDate);
    } catch (e) {
      return dateString;
    }
  }
}
