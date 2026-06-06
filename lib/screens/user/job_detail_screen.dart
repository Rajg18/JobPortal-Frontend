import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../providers/application_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _applying  = false;
  bool _applied   = false;   // turns true after a successful apply in this session

  Future<void> _apply() async {
    if (_applying || _applied) return;

    setState(() => _applying = true);

    // ApplicationProvider was passed via ChangeNotifierProvider.value from HomeScreen.
    final provider = context.read<ApplicationProvider>();
    final ok = await provider.applyJob(widget.job.id);

    if (!mounted) return;
    setState(() {
      _applying = false;
      if (ok) _applied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      ok
          ? const SnackBar(
              content: Text('🎉 Application submitted successfully!'),
              backgroundColor: AppColors.success,
            )
          : SnackBar(
              content: Text(provider.error ?? 'Failed to apply. Please try again.'),
              backgroundColor: AppColors.error,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Company header ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      job.companyName.isNotEmpty
                          ? job.companyName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w800,
                        color: AppColors.background),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.companyName,
                        style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.gold)),
                      Text(job.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Info chips ────────────────────────────────────────────────
            Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                _infoChip(Icons.location_on_outlined, job.location),
                _infoChip(Icons.code_outlined, job.techStack),
                _infoChip(Icons.workspace_premium_outlined,
                    '${job.experienceRequired}+ years'),
                _infoChip(Icons.person_outline, 'Posted by ${job.postedBy}'),
              ],
            ),

            const SizedBox(height: 28),
            _sectionTitle('About this role'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.divider),
              ),
              child: Text(job.description,
                style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.7)),
            ),

            const SizedBox(height: 28),
            _sectionTitle('Requirements'),
            const SizedBox(height: 10),
            _requirementRow(Icons.code, 'Tech Stack', job.techStack),
            _requirementRow(Icons.location_city, 'Location', job.location),
            _requirementRow(Icons.star_border_purple500,
                'Experience Required', '${job.experienceRequired}+ years'),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── Apply button bar ──────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: _applied
            // ── Already applied state ──────────────────────────────────────
            ? Container(
                height: 52,
                decoration: BoxDecoration(
                  color:        AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Text('Application Submitted',
                      style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.success)),
                  ],
                ),
              )
            // ── Apply now button ──────────────────────────────────────────
            : SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _applying ? null : _apply,
                  child: _applying
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.background))
                      : const Text('Apply Now'),
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
    style: GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary));

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(label,
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _requirementRow(IconData icon, String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.skyBlue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(key,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted)),
              Text(value,
                style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
