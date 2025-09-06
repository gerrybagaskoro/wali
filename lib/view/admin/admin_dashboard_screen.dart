// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_to_list_in_spreads, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/model/report/report_list_response.dart';
import 'package:wali_app/preference/shared_preference.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Datum> _reports = [];
  bool _isLoading = true;
  Map<String, int> _statistics = {'masuk': 0, 'proses': 0, 'selesai': 0};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadReports(), _loadStatistics()]);
  }

  Future<void> _loadReports() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) return;

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
        setState(() {
          _reports = reportResponse.data;
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(Endpoint.statistik),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _statistics = {
            'masuk': responseData['data']['masuk'] ?? 0,
            'proses': responseData['data']['proses'] ?? 0,
            'selesai': responseData['data']['selesai'] ?? 0,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int reportId, String newStatus) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status diperbarui ke $newStatus')),
        );
        await _loadData(); // Reload data dan statistik
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> _deleteReport(int reportId) async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Laporan dihapus')));
        await _loadData(); // Reload data dan statistik
      }
    } catch (e) {
      print('Error deleting report: $e');
    }
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
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

  Widget _buildStatisticsCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'STATISTIK LAPORAN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Masuk', _statistics['masuk']!, Colors.orange),
                _buildStatItem('Proses', _statistics['proses']!, Colors.blue),
                _buildStatItem(
                  'Selesai',
                  _statistics['selesai']!,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin RT/RW'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  _buildStatisticsCard(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'DAFTAR LAPORAN WARGA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._reports
                      .map((report) => _buildReportCard(report))
                      .toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildReportCard(Datum report) {
    Color statusColor = Colors.grey;
    if (report.status == 'proses') statusColor = Colors.orange;
    if (report.status == 'selesai') statusColor = Colors.green;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    report.user.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        report.user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 12),
            Text(
              report.judul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(report.isi),
            const SizedBox(height: 8),
            if (report.lokasi != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    report.lokasi!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              'Dilaporkan: ${_formatDate(report.createdAt)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Action Buttons untuk Admin
            Row(
              children: [
                // Update Status
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: report.status,
                    items: ['masuk', 'proses', 'selesai'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _updateStatus(report.id, newStatus);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Ubah Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(report.id);
                  },
                ),
              ],
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

  void _showDeleteDialog(int reportId) {
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
              _deleteReport(reportId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
