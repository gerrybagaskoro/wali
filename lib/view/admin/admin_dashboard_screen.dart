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
  Future<Map<String, dynamic>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    initializeDateFormatting('id_ID', null);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = _fetchDashboardData();
    });
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception('Token tidak valid');

      final results = await Future.wait([
        _fetchReports(token),
        _fetchStatistics(token),
      ]);

      return {'reports': results[0], 'statistics': results[1]};
    } catch (e) {
      throw Exception('Gagal memuat data dashboard: $e');
    }
  }

  Future<List<Datum>> _fetchReports(String token) async {
    final response = await http.get(
      Uri.parse(Endpoint.laporan),
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
        _loadData();
      } else {
        _showErrorMessage('Gagal memperbarui status');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

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
        _loadData();
      } else {
        _showErrorMessage('Gagal menghapus laporan');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildDashboardContent());
  }

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

  Widget _buildSuccessState(List<Datum> reports, Map<String, int> statistics) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildStatisticsSection(statistics)),
          SliverToBoxAdapter(child: _buildReportsHeader()),
          reports.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReportCard(reports[index]),
                    childCount: reports.length,
                  ),
                ),
        ],
      ),
    );
  }

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

  Widget _buildReportsHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        '📋 Daftar Laporan Warga',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

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

  Widget _buildReportFooter(Datum report) {
    return Text(
      '⏰ Dilaporkan: ${_formatDateIndonesian(report.createdAt)}',
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    );
  }

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

  Color _getStatusColor(String status) {
    final statusColors = {
      'masuk': Colors.orange,
      'proses': Colors.blue,
      'selesai': Colors.green,
    };
    return statusColors[status] ?? Colors.grey;
  }

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

  String _formatDateIndonesian(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final format = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID');
      return format.format(date);
    } catch (e) {
      return dateString;
    }
  }
}
