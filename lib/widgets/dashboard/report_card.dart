import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:wali_app/model/auth/auth_response.dart' as auth_model;
import 'package:wali_app/model/report/report_list_response.dart'
    as report_model;
import 'package:wali_app/utils/date_utils.dart';
import 'package:wali_app/view/user/user_detail_report.dart';

class ReportCard extends StatelessWidget {
  final report_model.Datum report;
  final auth_model.User? currentUser;

  const ReportCard({
    super.key,
    required this.report,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isMyReport = report.user.id == currentUser?.id;
    final statusColor = _getStatusColor(report.status);

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
                  _buildHeader(isMyReport, statusColor),
                  const SizedBox(height: 8),
                  _buildContent(),
                  if (report.imageUrl != null) _buildImage(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMyReport, Color statusColor) {
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

  Widget _buildContent() {
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

  Widget _buildImage() {
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

  Widget _buildFooter() {
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
      final utcDate = DateTime.parse(dateString).toUtc();
      final localDate = utcDate.toLocal();
      return IndonesianDateUtils.formatDateTime(localDate);
    } catch (e) {
      return dateString;
    }
  }
}
