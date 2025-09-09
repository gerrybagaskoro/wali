import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:wali_app/model/auth/auth_response.dart' as auth_model;
import 'package:wali_app/model/report/report_list_response.dart'
    as report_model;
import 'package:wali_app/widgets/dashboard/empty_state.dart';
import 'package:wali_app/widgets/dashboard/loading_indicator.dart';
import 'package:wali_app/widgets/dashboard/report_card.dart';

class ReportsSection extends StatelessWidget {
  final List<report_model.Datum> reports;
  final bool hasMore;
  final auth_model.User? currentUser;

  const ReportsSection({
    super.key,
    required this.reports,
    required this.hasMore,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(message: 'Belum ada laporan'),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == reports.length) {
          return hasMore ? const LoadingIndicator() : const SizedBox();
        }

        return FadeInDown(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: index * 80),
          from: 20,
          child: SlideInDown(
            duration: const Duration(milliseconds: 700),
            delay: Duration(milliseconds: index * 60),
            from: 10,
            child: ReportCard(report: reports[index], currentUser: currentUser),
          ),
        );
      }, childCount: reports.length + (hasMore ? 1 : 0)),
    );
  }
}
