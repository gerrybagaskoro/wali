// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/model/report/report_list_response.dart';
import 'package:wali_app/preference/shared_preference.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // State variables
  Future<Map<String, dynamic>>? _dataFuture;
  final int _itemsPerPage = 10;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener for pagination
  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore) {
      _loadMoreData();
    }
  }

  // Initialize app
  void _initializeApp() {
    initializeDateFormatting('id_ID', null);
    _loadData();
  }

  // Load data
  void _loadData() {
    setState(() {
      _dataFuture = _fetchDashboardData();
    });
  }

  // Fetch dashboard data
  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception('Token tidak valid');

      final results = await Future.wait([
        _fetchReports(token, page: 1),
        _fetchStatistics(token),
      ]);

      final reports = results[0] as List<Datum>;
      _hasMore = reports.length == _itemsPerPage;
      _currentPage = 1;

      return {'reports': reports, 'statistics': results[1]};
    } catch (e) {
      throw Exception('Gagal memuat data dashboard: $e');
    }
  }

  // Fetch reports with pagination
  Future<List<Datum>> _fetchReports(String token, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('${Endpoint.laporan}?page=$page&per_page=$_itemsPerPage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final reportResponse = ReportListResponse.fromJson(
        json.decode(response.body),
      );
      return reportResponse.data;
    } else {
      throw Exception('HTTP ${response.statusCode}: Gagal memuat laporan');
    }
  }

  // Fetch statistics
  Future<Map<String, int>> _fetchStatistics(String token) async {
    final response = await http.get(
      Uri.parse(Endpoint.statistik),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'masuk': responseData['data']['masuk'] ?? 0,
        'proses': responseData['data']['proses'] ?? 0,
        'selesai': responseData['data']['selesai'] ?? 0,
      };
    } else {
      throw Exception('HTTP ${response.statusCode}: Gagal memuat statistik');
    }
  }

  // Load more data for pagination
  Future<void> _loadMoreData() async {
    if (!_hasMore) return;

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) return;

      final nextPage = _currentPage + 1;
      final newReports = await _fetchReports(token, page: nextPage);

      if (newReports.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      final currentData = await _dataFuture;
      if (currentData == null) return;

      final currentReports = currentData['reports'] as List<Datum>;
      final updatedReports = [...currentReports, ...newReports];

      setState(() {
        _dataFuture = Future.value({
          'reports': updatedReports,
          'statistics': currentData['statistics'],
        });
        _currentPage = nextPage;
        _hasMore = newReports.length == _itemsPerPage;
      });
    } catch (e) {
      print('Error loading more data: $e');
    }
  }

  // Handle status update
  Future<void> _handleStatusUpdate(int reportId, String newStatus) async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) return;

      final response = await http.put(
        Uri.parse('${Endpoint.laporan}/$reportId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Status diperbarui ke $newStatus');
        _currentPage = 1;
        _hasMore = true;
        _loadData();
      } else {
        _showErrorMessage('Gagal memperbarui status');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  // Handle delete report
  Future<void> _handleDeleteReport(int reportId) async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('${Endpoint.laporan}/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Laporan berhasil dihapus');
        _currentPage = 1;
        _hasMore = true;
        _loadData();
      } else {
        _showErrorMessage('Gagal menghapus laporan');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  // Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Show logout confirmation
  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun admin?'),
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

  // Get status color
  Color _getStatusColor(String status) {
    final statusColors = {
      'masuk': Colors.orange,
      'proses': Colors.blue,
      'selesai': Colors.green,
    };
    return statusColors[status] ?? Colors.grey;
  }

  // Format date to Indonesian
  String _formatDateIndonesian(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final format = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID');
      return format.format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(int reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteReport(reportId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildDashboardContent());
  }

  // Build app bar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Pengelola Laporan',
        style: TextStyle(fontWeight: FontWeight.w300),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh Data',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _showLogoutConfirmation,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  // Build dashboard content
  Widget _buildDashboardContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error!);
        }

        if (snapshot.hasData) {
          final reports = snapshot.data!['reports'] as List<Datum>;
          final statistics = snapshot.data!['statistics'] as Map<String, int>;
          return _buildSuccessState(reports, statistics);
        }

        return const Center(child: Text('Tidak ada data yang tersedia'));
      },
    );
  }

  // Build error state
  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // Build success state
  Widget _buildSuccessState(List<Datum> reports, Map<String, int> statistics) {
    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 1;
        _hasMore = true;
        _loadData();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildStatisticsSection(statistics)),
          SliverToBoxAdapter(child: _buildReportsHeader()),
          reports.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == reports.length) {
                      return _hasMore
                          ? _buildLoadingIndicator()
                          : const SizedBox();
                    }
                    return _buildReportCard(reports[index]);
                  }, childCount: reports.length + (_hasMore ? 1 : 0)),
                ),
        ],
      ),
    );
  }

  // Build loading indicator
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // Build statistics section
  Widget _buildStatisticsSection(Map<String, int> statistics) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                '📊 Statistik Laporan',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatisticItem(
                    'Masuk',
                    statistics['masuk']!,
                    Colors.orange,
                  ),
                  _buildStatisticItem(
                    'Proses',
                    statistics['proses']!,
                    Colors.blue,
                  ),
                  _buildStatisticItem(
                    'Selesai',
                    statistics['selesai']!,
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build statistic item
  Widget _buildStatisticItem(String title, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Build reports header
  Widget _buildReportsHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        '📋 Daftar Laporan Warga',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada laporan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Build report card
  Widget _buildReportCard(Datum report) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportHeader(report),
              const SizedBox(height: 12),
              _buildReportContent(report),
              const SizedBox(height: 12),
              _buildReportImage(report),
              const SizedBox(height: 12),
              _buildReportFooter(report),
              const SizedBox(height: 12),
              _buildActionButtons(report),
            ],
          ),
        ),
      ),
    );
  }

  // Build report header
  Widget _buildReportHeader(Datum report) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            report.user.name[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                report.user.email,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        _buildStatusChip(report.status),
      ],
    );
  }

  // Build status chip
  Widget _buildStatusChip(String status) {
    final statusColors = {
      'masuk': Colors.orange,
      'proses': Colors.blue,
      'selesai': Colors.green,
    };

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: statusColors[status] ?? Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  // Build report content
  Widget _buildReportContent(Datum report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.judul,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(report.isi, style: const TextStyle(fontSize: 14)),
        if (report.lokasi != null && report.lokasi!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.lokasi!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Build report image
  Widget _buildReportImage(Datum report) {
    if (report.imageUrl == null || report.imageUrl!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📷 Foto Terlampir:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: report.imageUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.grey, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Gagal memuat gambar',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build report footer
  Widget _buildReportFooter(Datum report) {
    return Text(
      '⏰ Dilaporkan: ${_formatDateIndonesian(report.createdAt)}',
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    );
  }

  // Build action buttons
  Widget _buildActionButtons(Datum report) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: report.status,
            items: ['masuk', 'proses', 'selesai'].map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newStatus) {
              if (newStatus != null) {
                _handleStatusUpdate(report.id, newStatus);
              }
            },
            decoration: const InputDecoration(
              labelText: 'Ubah Status',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            isExpanded: true,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(report.id),
          tooltip: 'Hapus Laporan',
        ),
      ],
    );
  }
}
