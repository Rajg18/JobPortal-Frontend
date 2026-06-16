import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../providers/application_provider.dart';
import 'send_cold_email_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _applying = false;
  bool _applied  = false;

  @override
  void initState() {
    super.initState();
    // Ensure applications are loaded so hasAppliedToJob() is accurate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ApplicationProvider>();
      if (prov.myApplications.isEmpty && !prov.loading) {
        prov.loadMyApplications();
      }
    });
  }

  Future<void> _apply() async {
    if (_applying || _applied) return;
    setState(() => _applying = true);

    final provider = context.read<ApplicationProvider>();
    final ok = await provider.applyJob(widget.job.id);

    if (!mounted) return;
    setState(() {
      _applying = false;
      if (ok) _applied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      ok
          ? const SnackBar(content: Text('Application submitted successfully!'))
          : SnackBar(
              content: Text(provider.error ?? 'Failed to apply.'),
              backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final badgeColor = AppColors.badgeFor(job.companyName);
    final tags = job.techStack
        .split(RegExp(r'[,|/\s]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded,
                color: AppColors.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Company header card ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        job.companyName.isNotEmpty
                            ? job.companyName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                        const SizedBox(height: 3),
                        Text(job.companyName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Info pills ────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoPill(Icons.location_on_outlined, job.location,
                    AppColors.info),
                _infoPill(Icons.workspace_premium_outlined,
                    '${job.experienceRequired}+ yrs exp',
                    AppColors.warning),
                _infoPill(Icons.person_outline,
                    'by ${job.postedBy}', AppColors.accent),
              ],
            ),

            const SizedBox(height: 24),

            // ── About section ─────────────────────────────────────────────
            _sectionHeading('About this role'),
            const SizedBox(height: 10),
            Text(job.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              )),

            const SizedBox(height: 24),

            // ── Skills section ────────────────────────────────────────────
            _sectionHeading('Skills & Tech Stack'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(t,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          )),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // ── Requirements ──────────────────────────────────────────────
            _sectionHeading('Requirements'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _reqRow('Tech Stack', job.techStack, Icons.code_rounded),
                  Divider(height: 1, color: AppColors.divider),
                  _reqRow('Location', job.location,
                      Icons.location_on_outlined),
                  Divider(height: 1, color: AppColors.divider),
                  _reqRow('Experience',
                      '${job.experienceRequired}+ years',
                      Icons.workspace_premium_outlined),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── Bottom apply bar ──────────────────────────────────────────────────
      bottomNavigationBar: Builder(builder: (ctx) {
        final alreadyApplied = _applied ||
            context.watch<ApplicationProvider>().hasAppliedToJob(
              widget.job.id,
              title:   widget.job.title,
              company: widget.job.companyName,
            );
        return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: alreadyApplied
            ? Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Text('Application Submitted',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      )),
                  ],
                ),
              )
            : Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SendColdEmailScreen(job: widget.job)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Cold Email'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.divider),
                        foregroundColor: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _applying ? null : _apply,
                      child: _applying
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Apply Now'),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 16),
                              ],
                            ),
                    ),
                  ),
                ),
              ]),
        );
      }),
    );
  }

  Widget _sectionHeading(String title) => Text(title,
    style: GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary));

  Widget _infoPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _reqRow(String key, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text('$key  ',
            style: GoogleFonts.inter(
              fontSize: 12, color: AppColors.textMuted)),
          Expanded(
            child: Text(value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
