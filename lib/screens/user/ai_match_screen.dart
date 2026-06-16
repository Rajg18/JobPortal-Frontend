import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/profile_provider.dart';
import 'job_detail_screen.dart';
import 'send_cold_email_screen.dart';

class AiMatchScreen extends StatefulWidget {
  final VoidCallback? onGoHome;
  const AiMatchScreen({super.key, this.onGoHome});
  @override
  State<AiMatchScreen> createState() => _AiMatchScreenState();
}

class _AiMatchScreenState extends State<AiMatchScreen> {
  List<JobModel> _matchedJobs = [];
  bool    _loading = false;
  String? _error;
  bool    _fetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMatches());
  }

  Future<void> _loadMatches() async {
    final token = context.read<AuthProvider>().token ?? '';
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.matchJobs),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        setState(() {
          _matchedJobs = list.map((e) => JobModel.fromJson(e as Map<String, dynamic>)).toList();
          _fetched = true;
        });
      } else if (res.statusCode == 500) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => _error = body['message'] as String? ?? 'No resume found. Please upload your resume first.');
      } else {
        setState(() => _error = 'Unable to fetch matches (${res.statusCode})');
      }
    } catch (e) {
      setState(() => _error = 'Connection error. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final w       = MediaQuery.of(context).size.width;
    final isWide  = w > 900;
    final hPad    = isWide ? ((w - 1100) / 2).clamp(24.0, double.infinity) : 24.0;
    final pad     = EdgeInsets.symmetric(horizontal: hPad);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _loadMatches,
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true, floating: false,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 64,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: pad,
                child: Row(children: [
                  if (widget.onGoHome != null) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      color: AppColors.textSecondary,
                      tooltip: 'Back to Home',
                      onPressed: widget.onGoHome,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Text('AI Job Matches',
                    style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
                  const Spacer(),
                  if (!_loading)
                    Tooltip(
                      message: 'Refresh matches',
                      child: GestureDetector(
                        onTap: _loadMatches,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.refresh_rounded,
                              size: 20, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  if (_loading)
                    const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary)),
                ]),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.divider),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: pad.add(const EdgeInsets.only(top: 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── How it works banner ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'HireLoop reads your uploaded resume, extracts your tech stack using AI, '
                            'and finds jobs that match your skills automatically.',
                            style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF8B5CF6),
                              height: 1.5),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 20),

                    // ── Resume status chip ───────────────────────────────────
                    if (profile != null)
                      _resumeStatusChip(profile.resumeUploaded,
                          profile.parsedTechStackList.isNotEmpty),

                    const SizedBox(height: 20),

                    // ── Content ──────────────────────────────────────────────
                    if (_loading)
                      _loadingState()
                    else if (_error != null)
                      _errorState()
                    else if (_fetched && _matchedJobs.isEmpty)
                      _emptyState()
                    else if (_matchedJobs.isNotEmpty) ...[
                      Row(children: [
                        Text('Matched Roles for You',
                          style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${_matchedJobs.length} found',
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      ..._matchedJobs.map((job) => _MatchedJobCard(
                        job: job,
                        onViewDetails: () => _openJob(job),
                        onSendEmail:   () => _openSendEmail(job),
                      )),
                    ],

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumeStatusChip(bool uploaded, bool parsed) {
    if (parsed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 15, color: AppColors.success),
          const SizedBox(width: 7),
          Text('Resume parsed — your tech stack is ready for matching',
            style: GoogleFonts.inter(
              fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500)),
        ]),
      );
    }
    if (uploaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.warning)),
          const SizedBox(width: 8),
          Text('AI is parsing your resume — matches will appear shortly',
            style: GoogleFonts.inter(
              fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w500)),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.upload_file_rounded,
            size: 15, color: AppColors.error),
        const SizedBox(width: 7),
        Text('No resume uploaded — go to Profile to upload your resume',
          style: GoogleFonts.inter(
            fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _loadingState() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 80),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      SizedBox(height: 16),
      Text('Finding jobs that match your skills…',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
    ])),
  );

  Widget _errorState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.psychology_alt_outlined,
          size: 48, color: AppColors.textMuted),
      const SizedBox(height: 14),
      Text(_error!,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        textAlign: TextAlign.center),
      const SizedBox(height: 6),
      Text('Upload your resume from the Profile tab first,\nthen come back here.',
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
        textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: _loadMatches,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Try Again'),
      ),
    ])),
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 70),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
      const SizedBox(height: 14),
      Text('No matching jobs found right now',
        style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Text('New jobs are added regularly — check back soon.',
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
    ])),
  );

  void _openJob(JobModel job) {
    final appProvider = context.read<ApplicationProvider>();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: appProvider,
        child: JobDetailScreen(job: job),
      ),
    ));
  }

  void _openSendEmail(JobModel job) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SendColdEmailScreen(job: job),
    ));
  }
}

// ── Matched job card with two actions ─────────────────────────────────────────
class _MatchedJobCard extends StatelessWidget {
  final JobModel     job;
  final VoidCallback onViewDetails;
  final VoidCallback onSendEmail;
  const _MatchedJobCard({
    required this.job,
    required this.onViewDetails,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = AppColors.badgeFor(job.companyName);
    final tags = job.techStack
        .split(RegExp(r'[,]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(4)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title,
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(job.companyName,
                  style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
              ],
            )),
            // Match badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 11, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 4),
                Text('AI Match',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B5CF6))),
              ]),
            ),
          ]),

          const SizedBox(height: 10),

          // Location + experience
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 12, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text(job.location,
              style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(width: 12),
            const Icon(Icons.workspace_premium_outlined,
                size: 12, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text('${job.experienceRequired}+ yrs',
              style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textMuted)),
          ]),

          const SizedBox(height: 10),

          // Tech tags
          Wrap(
            spacing: 6, runSpacing: 6,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(t,
                style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
            )).toList(),
          ),

          const SizedBox(height: 14),

          // Action buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('View Details'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: AppColors.divider),
                  foregroundColor: AppColors.textSecondary,
                  textStyle: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onSendEmail,
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('Send Cold Email'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
