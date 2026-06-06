import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/job_provider.dart';
import '../../providers/application_provider.dart';
import '../../widgets/job_card.dart';
import 'create_job_screen.dart';
import 'job_applicants_screen.dart';

class JobsManagementScreen extends StatefulWidget {
  const JobsManagementScreen({super.key});

  @override
  State<JobsManagementScreen> createState() => _JobsManagementScreenState();
}

class _JobsManagementScreenState extends State<JobsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().loadJobs(reset: true);
    });
  }

  // ── Navigate to Create Job — pass JobProvider into the new route ─────────
  void _openCreateJob() {
    final jobProvider = context.read<JobProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: jobProvider,
          child: const CreateJobScreen(),
        ),
      ),
    );
  }

  // ── Navigate to Applicants — pass both providers into the new route ──────
  void _openApplicants(job) {
    final jobProvider = context.read<JobProvider>();
    final appProvider = context.read<ApplicationProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: jobProvider),
            ChangeNotifierProvider.value(value: appProvider),
          ],
          child: JobApplicantsScreen(job: job),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int jobId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Job?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "$title"? This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: Text('Delete',
              style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await context.read<JobProvider>().deleteJob(jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          ok
            ? const SnackBar(
                content: Text('Job deleted successfully'),
                backgroundColor: AppColors.success)
            : const SnackBar(
                content: Text('Delete failed'),
                backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Job Postings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => jobs.loadJobs(reset: true),
          ),
        ],
      ),

      // ── Post Job FAB ───────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateJob,
        icon:  const Icon(Icons.add, size: 20),
        label: Text('Post Job',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
      ),

      body: jobs.loading && jobs.jobs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : jobs.jobs.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () => jobs.loadJobs(reset: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: jobs.jobs.length,
                    itemBuilder: (_, i) {
                      final job = jobs.jobs[i];
                      return Column(
                        children: [
                          // Job card (tap → applicants, delete icon → confirm delete)
                          JobCard(
                            job:      job,
                            onTap:    () => _openApplicants(job),
                            onDelete: () => _confirmDelete(job.id, job.title),
                          ),

                          // View Applicants button below each card
                          GestureDetector(
                            onTap: () => _openApplicants(job),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: AppColors.skyBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.skyBlue.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.people_outline,
                                    size: 16, color: AppColors.skyBlue),
                                  const SizedBox(width: 8),
                                  Text('View Applicants',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.skyBlue)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.work_off_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No jobs posted yet',
            style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Tap the button below to post your first job',
            style: GoogleFonts.poppins(
              fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openCreateJob,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Post First Job'),
          ),
        ],
      ),
    );
  }
}
