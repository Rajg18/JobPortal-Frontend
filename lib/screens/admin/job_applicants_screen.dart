import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../providers/application_provider.dart';
import '../../widgets/status_badge.dart';

class JobApplicantsScreen extends StatefulWidget {
  final JobModel job;
  const JobApplicantsScreen({super.key, required this.job});

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().loadApplicants(widget.job.id);
    });
  }

  Future<void> _updateStatus(int appId, String currentStatus) async {
    final statuses = ['PENDING', 'ACCEPTED', 'REJECTED'];
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Application Status',
              style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...statuses.map((s) {
              final isActive = s == currentStatus;
              final color = s == 'ACCEPTED' ? AppColors.success
                           : s == 'REJECTED' ? AppColors.error
                           : AppColors.warning;
              return GestureDetector(
                onTap: () => Navigator.pop(context, s),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color:        isActive ? color.withValues(alpha: 0.15) : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(
                      color: isActive ? color : AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(_statusIcon(s), color: color, size: 18),
                      const SizedBox(width: 12),
                      Text(s,
                        style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                      const Spacer(),
                      if (isActive) Icon(Icons.check_circle, color: color, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
    if (chosen != null && chosen != currentStatus && mounted) {
      final provider = context.read<ApplicationProvider>();
      final ok = await provider.updateStatus(appId, chosen);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          ok
              ? SnackBar(content: Text('Status updated to $chosen'), backgroundColor: AppColors.success)
              : const SnackBar(content: Text('Update failed'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  IconData _statusIcon(String s) =>
    s == 'ACCEPTED' ? Icons.check_circle_outline
    : s == 'REJECTED' ? Icons.cancel_outlined
    : Icons.hourglass_empty;

  @override
  Widget build(BuildContext context) {
    final apps = context.watch<ApplicationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.title, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Job header bar ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                const Icon(Icons.business_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(widget.job.companyName,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                Text('${apps.jobApplicants.length} applicants',
                  style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold)),
              ],
            ),
          ),

          Expanded(
            child: apps.loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : apps.jobApplicants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline, size: 56, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('No applicants yet',
                              style: GoogleFonts.poppins(
                                fontSize: 15, color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: apps.jobApplicants.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final app = apps.jobApplicants[i];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:        AppColors.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border:       Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    color:  AppColors.skyBlue.withValues(alpha: 0.12),
                                    shape:  BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('${i + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14, fontWeight: FontWeight.w700,
                                        color: AppColors.skyBlue)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Application #${app.id}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13, fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text(_formatDate(app.appliedAt),
                                        style: GoogleFonts.poppins(
                                          fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _updateStatus(app.id, app.status),
                                  child: StatusBadge(status: app.status),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right,
                                  color: AppColors.textMuted, size: 16),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
