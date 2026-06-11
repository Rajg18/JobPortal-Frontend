import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/application_provider.dart';
import '../../widgets/status_badge.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final apps = context.watch<ApplicationProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => context.read<ApplicationProvider>().loadMyApplications(),
          ),
        ],
      ),
      body: apps.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : apps.myApplications.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () => context.read<ApplicationProvider>().loadMyApplications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: apps.myApplications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final app = apps.myApplications[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:        AppColors.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border:       Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            // Company avatar
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color:        AppColors.skyBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  app.companyName.isNotEmpty
                                      ? app.companyName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    color: AppColors.skyBlue),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.jobTitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 14, fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(app.companyName,
                                    style: GoogleFonts.inter(
                                      fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(height: 6),
                                  Text(_formatDate(app.appliedAt),
                                    style: GoogleFonts.inter(
                                      fontSize: 10, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            StatusBadge(status: app.status),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return 'Applied ${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No applications yet',
            style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Browse jobs and start applying!',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
