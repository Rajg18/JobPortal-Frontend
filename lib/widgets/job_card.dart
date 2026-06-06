import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../data/models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel  job;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const JobCard({super.key, required this.job, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:        AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(
              children: [
                // Company avatar
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color:        AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      job.companyName.isNotEmpty
                          ? job.companyName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(job.companyName,
                        style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:        AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // ── Tags row ────────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _tag(Icons.location_on_outlined, job.location),
                _tag(Icons.code_outlined, job.techStack),
                _tag(Icons.workspace_premium_outlined, '${job.experienceRequired}+ yrs'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
