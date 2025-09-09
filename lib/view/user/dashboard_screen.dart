// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'dart:convert';

// import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/extension/navigation.dart';
import 'package:wali_app/model/auth/auth_response.dart' as auth_model;
import 'package:wali_app/model/report/report_list_response.dart'
    as report_model;
import 'package:wali_app/preference/shared_preference.dart';
import 'package:wali_app/utils/app_logo_dashboard.dart';
import 'package:wali_app/utils/carousel_items.dart';
import 'package:wali_app/utils/snackbar_utils.dart';
import 'package:wali_app/view/user/user_add_report.dart';
import 'package:wali_app/widgets/dashboard/carousel_section.dart';
// import 'package:wali_app/widgets/dashboard/empty_state.dart';
import 'package:wali_app/widgets/dashboard/error_state.dart';
import 'package:wali_app/widgets/dashboard/header_section.dart';
import 'package:wali_app/widgets/dashboard/report_section.dart';
// import 'package:wali_app/widgets/dashboard/reports_section.dart';
import 'package:wali_app/widgets/dashboard/switch_menu_delegate.dart';
import 'package:wali_app/widgets/dashboard/switch_menu_section.dart';

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

      final userData = await _loadUserData();
      final reportsData = await _loadReports(token, page: 1);

      return {
        'user': userData,
        'reports': reportsData?['reports'] ?? <report_model.Datum>[],
        'hasMore': reportsData?['hasMore'] ?? false,
        'currentPage': 1,
      };
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Gagal memuat dashboard');
      }
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
        if (mounted) {
          SnackbarUtils.showError(
            context,
            'HTTP ${response.statusCode}: Gagal ambil laporan',
          );
        }
        return null;
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error saat memuat laporan');
      }
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
      if (mounted) {
        SnackbarUtils.showError(context, 'Gagal memuat laporan tambahan');
      }
    }
  }

  Future<void> _handleRefresh() async {
    _loadDashboardData();
    if (mounted) {
      SnackbarUtils.showInfo(context, 'Dashboard diperbarui');
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
        // title: const Text('Warga Peduli', style: TextStyle(fontSize: 20)),
        title: const AppLogoDashboard(width: 140, height: 140),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Perbarui',
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
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _loadDashboardData,
            );
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
          final result = await context.push<bool>(const UserAddReport());
          if (result == true && mounted) {
            _loadDashboardData();
            SnackbarUtils.showSuccess(context, 'Laporan berhasil ditambahkan!');
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

  Widget _buildSuccessState(List<report_model.Datum> reports, bool hasMore) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: HeaderSection(currentUser: _currentUser)),
          SliverToBoxAdapter(
            child: CarouselSection(carouselItems: carouselItems),
          ),
          // ✅ Switch menu tetap nempel
          SliverPersistentHeader(
            pinned: true,
            delegate: SwitchMenuDelegate(
              SwitchMenuSection(
                showMyReports: _showMyReports,
                onToggle: (value) {
                  setState(() => _showMyReports = value);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          ReportsSection(
            reports: reports,
            hasMore: hasMore,
            currentUser: _currentUser,
          ),
        ],
      ),
    );
  }
}
