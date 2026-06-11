import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../data/models/job_model.dart';

class JobCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool featured;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onDelete,
    this.featured = false,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final badgeColor = AppColors.badgeFor(widget.job.companyName);
    final tags = _parseTags(widget.job.techStack);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF222226) : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? AppColors.primary.withValues(alpha: 0.4) : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company badge
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.job.companyName.isNotEmpty
                            ? widget.job.companyName[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.job.companyName,
                          style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(widget.job.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            if (widget.featured) ...[
                              const SizedBox(width: 8),
                              _featuredBadge(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.onDelete != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 16),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // ── Meta pills ─────────────────────────────────────────────
              Wrap(
                spacing: 6, runSpacing: 6,
                children: [
                  _pill(Icons.location_on_outlined, widget.job.location),
                  _pill(Icons.access_time_outlined,
                      '${widget.job.experienceRequired}+ yrs'),
                ],
              ),

              if (tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: tags.take(4)
                      .map((t) => _skillTag(t))
                      .toList(),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),

              // ── Footer ─────────────────────────────────────────────────
              Row(
                children: [
                  Text(widget.job.postedBy,
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _hovered ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _hovered ? AppColors.primary : AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Apply',
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: _hovered
                                ? Colors.white
                                : AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                          size: 12,
                          color: _hovered
                              ? Colors.white
                              : AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
    ),
    child: Text('Featured',
      style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: AppColors.warning)),
  );

  Widget _pill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, color: AppColors.textSecondary)),
      ],
    ),
  );

  Widget _skillTag(String tag) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.accentBg,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(tag,
      style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.primaryLight)),
  );

  List<String> _parseTags(String s) => s
      .split(RegExp(r'[,|/\s]+'))
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();
}
