import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/application_provider.dart';
import '../../widgets/job_card.dart';
import 'job_detail_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _keywordCtrl  = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _companyCtrl  = TextEditingController();
  final _expCtrl      = TextEditingController();
  final _scrollCtrl   = ScrollController();

  int  _selectedTab  = 0;
  bool _showFilters  = false;

  // (label, techStack, location)
  static const List<(String, String?, String?)> _tabs = [
    ('All',         null,            null),
    ('Remote',      null,            'Remote'),
    ('Full-time',   'Full-time',     null),
    ('Contract',    'Contract',      null),
    ('Engineering', 'Engineering',   null),
    ('Design',      'Design',        null),
    ('Product',     'Product',       null),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<JobProvider>().loadJobs(reset: true));
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<JobProvider>().loadJobs();
    }
  }

  // Called from Search button, Enter key, trending tag tap
  Future<void> _search() async {
    final keyword  = _keywordCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final company  = _companyCtrl.text.trim();
    final exp      = int.tryParse(_expCtrl.text.trim());

    await context.read<JobProvider>().applyFilters(
      techStack:  keyword.isNotEmpty  ? keyword  : null,
      location:   location.isNotEmpty ? location : null,
      company:    company.isNotEmpty  ? company  : null,
      experience: exp,
    );
    if (mounted) setState(() => _showFilters = false);
  }

  Future<void> _clearAll() async {
    _keywordCtrl.clear();
    _locationCtrl.clear();
    _companyCtrl.clear();
    _expCtrl.clear();
    setState(() { _showFilters = false; _selectedTab = 0; });
    await context.read<JobProvider>().applyFilters();
  }

  Future<void> _onTab(int i) async {
    setState(() => _selectedTab = i);
    final (_, tech, loc) = _tabs[i];
    await context.read<JobProvider>().applyFilters(
      techStack: tech,
      location:  loc,
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  void _searchFromTag(String tag) {
    _keywordCtrl.text = tag;
    _search();
  }

  @override
  void dispose() {
    _keywordCtrl.dispose(); _locationCtrl.dispose();
    _companyCtrl.dispose(); _expCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final jobs   = context.watch<JobProvider>();
    final w      = MediaQuery.of(context).size.width;
    final isWide = w > 900;
    final hPad   = isWide ? ((w - 1100) / 2).clamp(24.0, double.infinity) : 24.0;
    final pad    = EdgeInsets.symmetric(horizontal: hPad);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [

          // ── Navbar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true, snap: true, pinned: false,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 64,
            titleSpacing: 0,
            title: Padding(
              padding: pad,
              child: Row(children: [
                // Brand
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.work_outline_rounded,
                        color: Color(0xFF0D0F12), size: 18)),
                ),
                const SizedBox(width: 9),
                Text('Hireloop',
                  style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),

                if (isWide) ...[
                  const SizedBox(width: 36),
                  _navLink('Find Jobs',       active: true),
                  _navLink('My Applications', active: false),
                ],

                const Spacer(),

                if (isWide) ...[
                  Text(auth.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                ],
                Tooltip(
                  message: 'Sign out',
                  child: InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        (auth.email ?? 'U')[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                    ),
                  ),
                ),
              ]),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.divider),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(pad),
                _buildFilterRow(pad, jobs),
                // Filter panel — shown/hidden via AnimatedContainer
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _showFilters
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: _buildAdvancedFilters(pad),
                  secondChild: const SizedBox.shrink(),
                ),
                _buildJobsSection(pad, jobs, isWide),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String label, {required bool active}) => Padding(
    padding: const EdgeInsets.only(right: 28),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(label,
        style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: active ? AppColors.textPrimary : AppColors.textSecondary)),
    ),
  );

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero(EdgeInsets pad) {
    return Container(
      width: double.infinity,
      padding: pad.add(const EdgeInsets.symmetric(vertical: 60)),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Headline — two lines, second in emerald
          Text('Find work that',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 52, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, height: 1.1,
              letterSpacing: -1.5)),
          Text('moves you forward.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 52, fontWeight: FontWeight.w800,
              color: AppColors.primary, height: 1.1,
              letterSpacing: -1.5)),

          const SizedBox(height: 16),
          Text(
            'A curated marketplace of senior engineering, design,\nand product roles at companies that take craft seriously.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15, color: AppColors.textSecondary, height: 1.65)),

          const SizedBox(height: 36),

          // ── Search bar ─────────────────────────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _keywordCtrl,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Role or tech stack (e.g. Flutter, Java)',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                Container(width: 1, height: 26, color: AppColors.divider),
                const SizedBox(width: 14),
                Icon(Icons.location_on_outlined, size: 16,
                    color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _locationCtrl,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: "Location or 'Remote'",
                      hintStyle: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 6),
                // Search button — GestureDetector to avoid web tap issues
                GestureDetector(
                  onTap: _search,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(9),
                        bottomRight: Radius.circular(9),
                      ),
                    ),
                    child: Center(
                      child: Text('Search jobs',
                        style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: const Color(0xFF0D0F12))),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 18),

          // Trending tags
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6, runSpacing: 6,
            children: [
              Text('Trending:',
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
              ...['React', 'Flutter', 'Java', 'Python', 'Remote', 'ML Engineer']
                  .map((t) => GestureDetector(
                        onTap: () => _searchFromTag(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(t,
                            style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary)),
                        ),
                      )),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter tabs + Filters toggle — kept in ONE widget ─────────────────────
  Widget _buildFilterRow(EdgeInsets pad, JobProvider jobs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top:    BorderSide(color: AppColors.divider),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: pad.left,
        vertical: 0,
      ),
      child: Row(children: [
        // Scrollable tab row
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final sel = _selectedTab == i;
                return GestureDetector(
                  onTap: () => _onTab(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.divider),
                    ),
                    child: Text(_tabs[i].$1,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? AppColors.primary : AppColors.textSecondary)),
                  ),
                );
              }),
            ),
          ),
        ),

        // ── Filters toggle button (GestureDetector avoids web tap issues) ──
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _showFilters = !_showFilters),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _showFilters
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _showFilters ? AppColors.primary : AppColors.inputBorder,
                width: _showFilters ? 1.5 : 1,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                _showFilters ? Icons.tune_rounded : Icons.tune_rounded,
                size: 16,
                color: _showFilters ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('Filters',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: _showFilters ? FontWeight.w600 : FontWeight.w400,
                  color: _showFilters ? AppColors.primary : AppColors.textSecondary)),
              if (_showFilters) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle),
                ),
              ],
            ]),
          ),
        ),
        const SizedBox(width: 4),
      ]),
    );
  }

  // ── Advanced filter panel ──────────────────────────────────────────────────
  Widget _buildAdvancedFilters(EdgeInsets pad) {
    return Container(
      padding: EdgeInsets.fromLTRB(pad.left, 16, pad.right, 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _filterInput(_companyCtrl, 'Company name', Icons.business_outlined),
          _filterInput(_expCtrl, 'Min experience (yrs)',
              Icons.workspace_premium_outlined,
              keyType: TextInputType.number),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _search,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 20)),
              child: const Text('Apply filters'),
            ),
          ),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: _clearAll,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: const BorderSide(color: AppColors.divider),
                foregroundColor: AppColors.textSecondary),
              child: const Text('Clear all'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterInput(TextEditingController c, String hint, IconData icon,
      {TextInputType keyType = TextInputType.text}) =>
      SizedBox(
        width: 210, height: 40,
        child: TextField(
          controller: c,
          keyboardType: keyType,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 14, color: AppColors.textMuted),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      );

  // ── Jobs section ───────────────────────────────────────────────────────────
  Widget _buildJobsSection(EdgeInsets pad, JobProvider jobs, bool isWide) {
    return Padding(
      padding: pad.add(const EdgeInsets.only(top: 32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Open Positions',
                style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, letterSpacing: -0.4)),
              const SizedBox(width: 10),
              if (!jobs.loading && jobs.jobs.isNotEmpty)
                Text('${jobs.jobs.length} roles',
                  style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textMuted)),
              const Spacer(),
              // Show error if any
              if (jobs.error != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline,
                        size: 13, color: AppColors.error),
                    const SizedBox(width: 6),
                    Text(jobs.error!,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.error)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.read<JobProvider>().loadJobs(reset: true),
                      child: Text('Retry',
                        style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppColors.error,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.error)),
                    ),
                  ]),
                ),
              if (jobs.loading && jobs.jobs.isNotEmpty)
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary)),
            ],
          ),

          const SizedBox(height: 20),

          if (jobs.loading && jobs.jobs.isEmpty)
            _loadingState()
          else if (!jobs.loading && jobs.jobs.isEmpty && jobs.error == null)
            _emptyState()
          else if (jobs.error != null && jobs.jobs.isEmpty)
            _errorState(jobs.error!)
          else
            _JobGrid(jobs: jobs, onTap: _openJob, isWide: isWide),
        ],
      ),
    );
  }

  Widget _loadingState() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 80),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 28, height: 28,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.primary)),
        SizedBox(height: 14),
        Text('Loading jobs…',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ]),
    ),
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 80),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(Icons.search_off_rounded,
              size: 32, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Text('No jobs found',
          style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text('Try different keywords or clear filters',
          style: GoogleFonts.inter(
            fontSize: 13, color: AppColors.textMuted)),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: _clearAll,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.divider),
            foregroundColor: AppColors.textSecondary),
          child: const Text('Clear filters'),
        ),
      ]),
    ),
  );

  Widget _errorState(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded,
            size: 40, color: AppColors.textMuted),
        const SizedBox(height: 14),
        Text(msg,
          style: GoogleFonts.inter(
            fontSize: 13, color: AppColors.textSecondary),
          textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () =>
              context.read<JobProvider>().loadJobs(reset: true),
          child: const Text('Retry'),
        ),
      ]),
    ),
  );

  void _openJob(dynamic job) {
    final appProvider = context.read<ApplicationProvider>();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: appProvider,
        child: JobDetailScreen(job: job),
      ),
    ));
  }
}

// ── Responsive 2-column job grid ─────────────────────────────────────────────
class _JobGrid extends StatelessWidget {
  final JobProvider jobs;
  final Function(dynamic) onTap;
  final bool isWide;
  const _JobGrid({required this.jobs, required this.onTap, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final list = jobs.jobs;
    if (isWide) {
      return Column(
        children: [
          for (int i = 0; i < list.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: JobCard(
                    job: list[i], featured: i % 5 == 0,
                    onTap: () => onTap(list[i]))),
                  const SizedBox(width: 12),
                  if (i + 1 < list.length)
                    Expanded(child: JobCard(
                      job: list[i + 1], featured: (i + 1) % 5 == 0,
                      onTap: () => onTap(list[i + 1])))
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          if (jobs.hasMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.primary)))),
        ],
      );
    }
    return Column(
      children: [
        ...list.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JobCard(
            job: e.value, featured: e.key % 5 == 0,
            onTap: () => onTap(e.value)))),
        if (jobs.hasMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.primary)))),
      ],
    );
  }
}
