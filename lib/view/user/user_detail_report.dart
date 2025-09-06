// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/model/report/report_detail_response.dart';
import 'package:wali_app/model/report/report_list_response.dart';
import 'package:wali_app/preference/shared_preference.dart';

class DetailLaporanScreen extends StatefulWidget {
  final int laporanId;
  final bool isMyReport;

  const DetailLaporanScreen({
    super.key,
    required this.laporanId,
    required this.isMyReport,
  });

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  ReportDetailData? _laporanDetail;
  bool _isLoading = true;
  bool _isEditing = false;
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final _lokasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadLaporanDetail();
  }

  Future<void> _loadLaporanDetail() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Token tidak valid')));
        return;
      }

      print('🔍 Mengambil data dari list laporan...');

      // Ambil semua laporan
      final response = await http
          .get(
            Uri.parse(Endpoint.laporan),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('🔍 DEBUG - List Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Parse response list
        final listResponse = ReportListResponse.fromJson(responseData);

        // Cari laporan dengan ID yang sesuai
        final foundReport = listResponse.data.firstWhere(
          (report) => report.id == widget.laporanId,
        );

        // Convert dari model list ke model detail
        setState(() {
          _laporanDetail = ReportDetailData(
            id: foundReport.id,
            userId: foundReport.userId.toString(),
            judul: foundReport.judul,
            isi: foundReport.isi,
            status: foundReport.status,
            createdAt: foundReport.createdAt,
            updatedAt: foundReport.updatedAt.toString(),
            lokasi: foundReport.lokasi,
            imageUrl: foundReport.imageUrl,
          );
          _judulController.text = foundReport.judul;
          _isiController.text = foundReport.isi;
          _lokasiController.text = foundReport.lokasi ?? '';
          _isLoading = false;
        });

        print('✅ Detail laporan ditemukan: ${foundReport.judul}');
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Gagal mengambil list laporan',
        );
      }
    } catch (e) {
      print('❌ Error loading detail: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat detail: $e')));
    }
  }

  Future<void> _updateLaporan() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) return;

      final response = await http.put(
        Uri.parse('${Endpoint.laporan}/${widget.laporanId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'judul': _judulController.text,
          'isi': _isiController.text,
          'lokasi': _lokasiController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Setelah update berhasil, reload data dari list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diperbarui')),
        );

        // Reload data
        await _loadLaporanDetail();
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      print('Error updating: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final format = DateFormat('EEEE, d MMMM yyyy HH:mm', 'id_ID');
      return format.format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        actions: [
          if (widget.isMyReport && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (widget.isMyReport && _isEditing)
            IconButton(icon: const Icon(Icons.save), onPressed: _updateLaporan),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laporanDetail == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : _buildDetailContent(),
    );
  }

  Widget _buildDetailContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan avatar dan nama
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.shade100,
                child: Text(
                  'W',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'User ID: ${_laporanDetail!.userId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Judul (editable jika laporan saya)
          _isEditing
              ? TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Laporan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                )
              : Text(
                  _laporanDetail!.judul,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 16),

          // Lokasi (editable jika laporan saya)
          _isEditing
              ? TextFormField(
                  controller: _lokasiController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi',
                    border: OutlineInputBorder(),
                  ),
                )
              : _laporanDetail!.lokasi != null &&
                    _laporanDetail!.lokasi!.isNotEmpty
              ? Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _laporanDetail!.lokasi ?? '-',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : Container(),
          const SizedBox(height: 16),

          // Isi (editable jika laporan saya)
          _isEditing
              ? TextFormField(
                  controller: _isiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                )
              : Text(_laporanDetail!.isi, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),

          // Gambar
          if (_laporanDetail!.imageUrl != null &&
              _laporanDetail!.imageUrl!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Lampiran:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _laporanDetail!.imageUrl!,
                    width: double.infinity,
                    height: 320,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Status dan Timestamp
          Row(
            children: [
              Chip(
                label: Text(
                  _laporanDetail!.status.toUpperCase(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: _getStatusColor(_laporanDetail!.status),
              ),
              const Spacer(),
              // Text(
              //   _formatDate(_laporanDetail!.updatedAt),
              //   style: const TextStyle(fontSize: 12, color: Colors.grey),
              // ),
            ],
          ),

          // Info "Terakhir diperbarui"
          if (_laporanDetail!.updatedAt != _laporanDetail!.createdAt)
            Text(
              'Terakhir diperbarui: ${_formatDate(_laporanDetail!.updatedAt)}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
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

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }
}
