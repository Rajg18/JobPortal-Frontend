import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/application_provider.dart';
import '../../widgets/job_card.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();
  bool  _showFilters = false;

  final _locationCtrl  = TextEditingController();
  final _techCtrl      = TextEditingController();
  final _companyCtrl   = TextEditingController();
  final _expCtrl       = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().loadJobs(reset: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<JobProvider>().loadJobs();
    }
  }

  void _applyFilters() {
    context.read<JobProvider>().applyFilters(
      location:   _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      techStack:  _techCtrl.text.trim().isEmpty ? null : _techCtrl.text.trim(),
      company:    _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      experience: _expCtrl.text.trim().isEmpty ? null : int.tryParse(_expCtrl.text.trim()),
    );
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    _locationCtrl.clear();
    _techCtrl.clear();
    _companyCtrl.clear();
    _expCtrl.clear();
    context.read<JobProvider>().applyFilters();
    setState(() => _showFilters = false);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _locationCtrl.dispose();
    _techCtrl.dispose();
    _companyCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobs = context.watch<JobProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Find Your Dream Job',
                              style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                            Text(auth.email ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showFilters = !_showFilters),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _showFilters
                                ? AppColors.gold.withValues(alpha: 0.15)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _showFilters ? AppColors.gold : AppColors.divider),
                          ),
                          child: Icon(Icons.tune,
                            color: _showFilters ? AppColors.gold : AppColors.textSecondary,
                            size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Search bar (company name quick search)
                  TextField(
                    controller: _searchCtrl,
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText:   'Search by company or role...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _searchCtrl.clear();
                                _companyCtrl.clear();
                                _applyFilters();
                              })
                          : null,
                    ),
                    onChanged: (v) {
                      setState(() {});
                      _companyCtrl.text = v;
                      if (v.isEmpty) _applyFilters();
                    },
                    onSubmitted: (_) => _applyFilters(),
                  ),

                  // ── Filter panel ──────────────────────────────────────────
                  if (_showFilters) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:        AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _filterField(_locationCtrl, 'Location', Icons.location_on_outlined)),
                              const SizedBox(width: 10),
                              Expanded(child: _filterField(_techCtrl, 'Tech Stack', Icons.code)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _filterField(_expCtrl, 'Max Exp (yrs)', Icons.star_outline,
                                keyType: TextInputType.number)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _applyFilters,
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(0, 44),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Text('Apply'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _clearFilters,
                                      child: Container(
                                        height: 44, width: 44,
                                        decoration: BoxDecoration(
                                          color:        AppColors.surface,
                                          borderRadius: BorderRadius.circular(10),
                                          border:       Border.all(color: AppColors.divider),
                                        ),
                                        child: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Job list ─────────────────────────────────────────────────────
            Expanded(
              child: jobs.jobs.isEmpty && jobs.loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : jobs.jobs.isEmpty && !jobs.loading
                      ? _emptyState()
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: jobs.jobs.length + (jobs.hasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == jobs.jobs.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(color: AppColors.gold),
                                ));
                            }
                            final job = jobs.jobs[i];
                            return JobCard(
                              job: job,
                              onTap: () {
                                // Capture the provider BEFORE pushing — the new route
                                // is outside UserShell's MultiProvider scope so we
                                // must pass the existing instance via .value.
                                final appProvider = context.read<ApplicationProvider>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider.value(
                                      value: appProvider,
                                      child: JobDetailScreen(job: job),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyType = TextInputType.text}) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller:  ctrl,
        keyboardType: keyType,
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText:       label,
          hintStyle:      GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
          prefixIcon:     Icon(icon, size: 14, color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense:        true,
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
          Text('No jobs found',
            style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Try adjusting your filters',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
