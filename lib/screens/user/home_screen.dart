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
  final _locationCtrl = TextEditingController();
  final _techCtrl     = TextEditingController();
  final _expCtrl      = TextEditingController();
  int  _selectedTab  = 0;
  bool _showFilters  = false;

  static const _tabs = ['All', 'Remote', 'Full-time', 'Contract', 'Engineering', 'Design', 'Product'];

  static const _categories = [
    {'icon': Icons.code_rounded,              'label': 'Engineering',  'count': '8,420'},
    {'icon': Icons.palette_outlined,          'label': 'Design',       'count': '2,150'},
    {'icon': Icons.bar_chart_rounded,         'label': 'Data & AI',    'count': '3,200'},
    {'icon': Icons.campaign_outlined,         'label': 'Marketing',    'count': '1,840'},
    {'icon': Icons.account_balance_outlined,  'label': 'Finance',      'count': '1,320'},
    {'icon': Icons.support_agent_outlined,    'label': 'Support',      'count': '950'},
    {'icon': Icons.manage_accounts_outlined,  'label': 'Operations',   'count': '1,100'},
    {'icon': Icons.storefront_outlined,       'label': 'Sales',        'count': '2,600'},
  ];

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

  void _applySearch() {
    final q = _searchCtrl.text.trim();
    context.read<JobProvider>().applyFilters(
      location:  _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      techStack: _techCtrl.text.trim().isEmpty ? (q.isEmpty ? null : q) : _techCtrl.text.trim(),
      experience: _expCtrl.text.trim().isEmpty ? null : int.tryParse(_expCtrl.text.trim()),
    );
    setState(() => _showFilters = false);
  }

  void _clearAll() {
    _searchCtrl.clear(); _locationCtrl.clear();
    _techCtrl.clear(); _expCtrl.clear();
    setState(() { _showFilters = false; _selectedTab = 0; });
    context.read<JobProvider>().applyFilters();
  }

  void _onTab(int i) {
    setState(() => _selectedTab = i);
    final label = _tabs[i];
    context.read<JobProvider>().applyFilters(
      techStack: (i == 0) ? null : label,
      location:  (label == 'Remote') ? 'Remote' : null,
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose(); _scrollCtrl.dispose();
    _locationCtrl.dispose(); _techCtrl.dispose(); _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobs = context.watch<JobProvider>();
    final w    = MediaQuery.of(context).size.width;
    // Centered max-width layout for web
    final isWide = w > 900;
    final hPad   = isWide ? (w - 1100) / 2 : 0.0;
    final pad     = EdgeInsets.symmetric(horizontal: hPad < 24 ? 24.0 : hPad);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── Top nav bar ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true, snap: true, pinned: false,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 60,
            titleSpacing: 0,
            title: Padding(
              padding: pad,
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Center(
                      child: Text('H',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('HireLoop',
                    style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
                  const SizedBox(width: 32),
                  if (isWide) ...[
                    _navLink('Find Jobs'),
                    _navLink('Companies'),
                    _navLink('Categories'),
                  ],
                  const Spacer(),
                  Text(auth.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (auth.email ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.divider),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero ───────────────────────────────────────────────────
                _buildHero(pad),
                // ── Stats ──────────────────────────────────────────────────
                _buildStats(pad),
                // ── Search ─────────────────────────────────────────────────
                _buildSearch(pad),
                if (_showFilters) _buildFilters(pad),
                // ── Categories ─────────────────────────────────────────────
                _buildCategories(pad, isWide),
                // ── Jobs section ───────────────────────────────────────────
                _buildJobsSection(pad, jobs),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String label) => Padding(
    padding: const EdgeInsets.only(right: 24),
    child: Text(label,
      style: GoogleFonts.inter(
        fontSize: 13, color: AppColors.textSecondary,
        fontWeight: FontWeight.w500)),
  );

  Widget _buildHero(EdgeInsets pad) {
    return Container(
      width: double.infinity,
      padding: pad.add(const EdgeInsets.symmetric(vertical: 56)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF09090B), Color(0xFF131318), Color(0xFF09090B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text('32k+ open roles across 120+ countries',
              style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.primaryLight,
                fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 20),
          // Headline
          Text('Find work that\nmoves you forward',
            style: GoogleFonts.inter(
              fontSize: 44, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, height: 1.15,
              letterSpacing: -1.0)),
          const SizedBox(height: 14),
          Text('A curated marketplace of senior engineering,\ndesign, and product roles.',
            style: GoogleFonts.inter(
              fontSize: 15, color: AppColors.textSecondary, height: 1.6)),
          const SizedBox(height: 28),
          // Trending tags
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Flutter', 'Java', 'React', 'Python', 'Remote', 'Kotlin']
                .map((t) => GestureDetector(
                      onTap: () {
                        _searchCtrl.text = t;
                        _techCtrl.text = t;
                        _applySearch();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(t,
                          style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(EdgeInsets pad) => Container(
    width: double.infinity,
    padding: pad.add(const EdgeInsets.symmetric(vertical: 20)),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: AppColors.divider),
        bottom: BorderSide(color: AppColors.divider),
      ),
      color: AppColors.surface,
    ),
    child: Wrap(
      spacing: 40, runSpacing: 12,
      children: [
        _stat('32k+', 'Open roles'),
        _stat('8.4k', 'Hiring companies'),
        _stat('120+', 'Countries'),
        _stat('94%',  'Placement rate'),
      ],
    ),
  );

  Widget _stat(String value, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value,
        style: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary)),
      const SizedBox(width: 8),
      Text(label,
        style: GoogleFonts.inter(
          fontSize: 13, color: AppColors.textSecondary)),
    ],
  );

  Widget _buildSearch(EdgeInsets pad) => Padding(
    padding: pad.add(const EdgeInsets.only(top: 28, bottom: 4)),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search roles, companies, tech stack...',
              prefixIcon: const Icon(Icons.search, size: 18,
                  color: AppColors.textMuted),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16,
                          color: AppColors.textMuted),
                      onPressed: () { _searchCtrl.clear(); setState(() {}); _clearAll(); })
                  : null,
            ),
            onChanged: (v) => setState(() {}),
            onSubmitted: (_) => _applySearch(),
          ),
        ),
        const SizedBox(width: 8),
        // Filters toggle
        Tooltip(
          message: 'Advanced filters',
          child: InkWell(
            onTap: () => setState(() => _showFilters = !_showFilters),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _showFilters ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _showFilters ? AppColors.primary : AppColors.inputBorder),
              ),
              child: Icon(Icons.tune_rounded,
                color: _showFilters ? Colors.white : AppColors.textSecondary,
                size: 18),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Search button
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: _applySearch,
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text('Search',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );

  Widget _buildFilters(EdgeInsets pad) => Container(
    margin: pad.add(const EdgeInsets.only(top: 10)),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Refine results',
          style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _filterField(_locationCtrl, 'Location', Icons.location_on_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _filterField(_techCtrl, 'Tech / Role', Icons.code_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _filterField(_expCtrl, 'Max exp (yrs)',
                Icons.workspace_premium_outlined, keyType: TextInputType.number)),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _applySearch,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44), padding: const EdgeInsets.symmetric(horizontal: 20)),
              child: const Text('Apply'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _clearAll,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: const BorderSide(color: AppColors.divider),
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _filterField(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType keyType = TextInputType.text}) =>
    SizedBox(
      height: 44,
      child: TextField(
        controller: ctrl, keyboardType: keyType,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          prefixIcon: Icon(icon, size: 14, color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true,
        ),
      ),
    );

  Widget _buildCategories(EdgeInsets pad, bool isWide) {
    final cols = isWide ? 8 : 4;
    return Padding(
      padding: pad.add(const EdgeInsets.only(top: 36, bottom: 8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Explore by category',
                style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
              const Spacer(),
              Text('View all →',
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.primary,
                  fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat   = _categories[i];
              final icon  = cat['icon'] as IconData;
              final label = cat['label'] as String;
              final count = cat['count'] as String;
              final color = AppColors.badgeColors[i % AppColors.badgeColors.length];
              return _CategoryCard(
                icon: icon, label: label, count: count, color: color,
                onTap: () {
                  _techCtrl.text = label;
                  context.read<JobProvider>().applyFilters(techStack: label);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSection(EdgeInsets pad, JobProvider jobs) {
    return Padding(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          // Section header
          Row(
            children: [
              Text('Latest Opportunities',
                style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
              const SizedBox(width: 10),
              if (!jobs.loading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text('${jobs.jobs.length} roles',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary)),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final sel = _selectedTab == i;
                return GestureDetector(
                  onTap: () => _onTab(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.divider),
                    ),
                    child: Text(_tabs[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Job list
          if (jobs.jobs.isEmpty && jobs.loading)
            const Padding(
              padding: EdgeInsets.all(60),
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2)),
            )
          else if (jobs.jobs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(60),
              child: Center(
                child: Column(children: [
                  Icon(Icons.work_off_outlined,
                      size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No jobs found',
                    style: GoogleFonts.inter(
                      fontSize: 15, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('Try adjusting filters',
                    style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textMuted)),
                ]),
              ),
            )
          else
            _JobGrid(jobs: jobs, onTap: _openJob, featured: true),
        ],
      ),
    );
  }

  void _openJob(job) {
    final appProvider = context.read<ApplicationProvider>();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: appProvider,
        child: JobDetailScreen(job: job),
      ),
    ));
  }
}

// ── Responsive job grid (2-col on wide, 1-col on narrow) ─────────────────────
class _JobGrid extends StatelessWidget {
  final JobProvider jobs;
  final Function(dynamic) onTap;
  final bool featured;
  const _JobGrid({required this.jobs, required this.onTap, this.featured = false});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 900;

    if (isWide) {
      // Two-column grid
      return Column(
        children: [
          for (int i = 0; i < jobs.jobs.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: JobCard(
                      job: jobs.jobs[i],
                      featured: featured && i % 3 == 0,
                      onTap: () => onTap(jobs.jobs[i]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (i + 1 < jobs.jobs.length)
                    Expanded(
                      child: JobCard(
                        job: jobs.jobs[i + 1],
                        featured: featured && (i + 1) % 3 == 0,
                        onTap: () => onTap(jobs.jobs[i + 1]),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          if (jobs.hasMore)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2)),
            ),
        ],
      );
    }

    // Single-column list
    return Column(
      children: [
        ...jobs.jobs.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: JobCard(
            job: e.value,
            featured: featured && e.key % 3 == 0,
            onTap: () => onTap(e.value),
          ),
        )),
        if (jobs.hasMore)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2)),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final IconData icon;
  final String label, count;
  final Color color;
  final VoidCallback onTap;
  const _CategoryCard({required this.icon, required this.label,
    required this.count, required this.color, required this.onTap});
  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surface : AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.4)
                  : AppColors.divider),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 22, color: widget.color),
              const SizedBox(height: 6),
              Text(widget.label,
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(widget.count,
                style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
