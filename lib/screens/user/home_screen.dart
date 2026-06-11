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
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int _selectedFilter = 0;

  final _locationCtrl = TextEditingController();
  final _techCtrl     = TextEditingController();
  final _expCtrl      = TextEditingController();
  bool _showFilters   = false;

  static const _filterTabs = ['All', 'Remote', 'Full-time', 'Engineering', 'Design', 'Product'];

  static const _categories = [
    {'icon': Icons.code_rounded,          'label': 'Engineering'},
    {'icon': Icons.palette_outlined,      'label': 'Design'},
    {'icon': Icons.bar_chart_rounded,     'label': 'Data & AI'},
    {'icon': Icons.campaign_outlined,     'label': 'Marketing'},
    {'icon': Icons.account_balance_outlined, 'label': 'Finance'},
    {'icon': Icons.support_agent_outlined,'label': 'Support'},
    {'icon': Icons.manage_accounts_outlined, 'label': 'Operations'},
    {'icon': Icons.storefront_outlined,   'label': 'Sales'},
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
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<JobProvider>().loadJobs();
    }
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim();
    context.read<JobProvider>().applyFilters(
      location:  _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      techStack: _techCtrl.text.trim().isEmpty
          ? (q.isEmpty ? null : q)
          : _techCtrl.text.trim(),
      experience: _expCtrl.text.trim().isEmpty ? null : int.tryParse(_expCtrl.text.trim()),
    );
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    _searchCtrl.clear();
    _locationCtrl.clear();
    _techCtrl.clear();
    _expCtrl.clear();
    context.read<JobProvider>().applyFilters();
    setState(() { _showFilters = false; _selectedFilter = 0; });
  }

  void _onTabSelected(int i) {
    setState(() => _selectedFilter = i);
    final label = _filterTabs[i];
    context.read<JobProvider>().applyFilters(
      techStack: (i == 0) ? null : label,
      location:  (label == 'Remote') ? 'Remote' : null,
    );
  }

  void _onCategoryTap(String label) {
    _techCtrl.text = label;
    context.read<JobProvider>().applyFilters(techStack: label);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _locationCtrl.dispose();
    _techCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobs = context.watch<JobProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            // ── Sticky header ────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,
              toolbarHeight: 60,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Logo mark
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('H',
                          style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('HireLoop',
                      style: GoogleFonts.inter(
                        fontSize: 17, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const Spacer(),
                    // Notification bell
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: AppColors.textSecondary, size: 22),
                      onPressed: () {},
                    ),
                    // Avatar
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        (auth.email ?? 'U')[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppColors.divider),
              ),
            ),

            // ── All scrollable content ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero card ───────────────────────────────────────────────
                  _buildHero(auth.email),

                  // ── Stats row ───────────────────────────────────────────────
                  _buildStats(),

                  // ── Search bar ──────────────────────────────────────────────
                  _buildSearchBar(),

                  // ── Advanced filter panel ───────────────────────────────────
                  if (_showFilters) _buildFilterPanel(),

                  // ── Categories ──────────────────────────────────────────────
                  _buildCategories(),

                  // ── Filter tabs ─────────────────────────────────────────────
                  _buildFilterTabs(),

                  // ── Job count label ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text('Latest Opportunities',
                          style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                        const Spacer(),
                        if (!jobs.loading)
                          Text('${jobs.jobs.length} roles',
                            style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),

                  // ── Job list ────────────────────────────────────────────────
                  _buildJobList(jobs),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(String? email) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find work that\nmoves you forward',
            style: GoogleFonts.inter(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: Colors.white, height: 1.3)),
          const SizedBox(height: 8),
          Text('Discover top roles from the\nworld\'s leading companies.',
            style: GoogleFonts.inter(
              fontSize: 13, color: Colors.white60, height: 1.5)),
          const SizedBox(height: 18),
          // Trending tags
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Flutter', 'Java', 'React', 'Python', 'Remote']
                .map((tag) => GestureDetector(
                      onTap: () {
                        _searchCtrl.text = tag;
                        _applyFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(tag,
                          style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white,
                            fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _statItem('10k+', 'Open roles'),
          _statDivider(),
          _statItem('2.4k', 'Companies'),
          _statDivider(),
          _statItem('50+', 'Countries'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
            style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
    width: 1, height: 32, color: AppColors.divider);

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search roles, companies...',
                prefixIcon: const Icon(Icons.search, size: 20,
                    color: AppColors.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16,
                            color: AppColors.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                          _clearFilters();
                        })
                    : null,
              ),
              onChanged: (v) => setState(() {}),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 10),
          // Filter toggle
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _showFilters ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _showFilters ? AppColors.primary : AppColors.divider),
              ),
              child: Icon(Icons.tune_rounded,
                color: _showFilters ? Colors.white : AppColors.textSecondary,
                size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _filterField(_locationCtrl, 'Location',
                  Icons.location_on_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _filterField(
                  _techCtrl, 'Tech / Role', Icons.code_rounded)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _filterField(_expCtrl, 'Max exp (yrs)',
                  Icons.workspace_premium_outlined,
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
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: AppColors.textSecondary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterField(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType keyType = TextInputType.text}) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: ctrl,
        keyboardType: keyType,
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
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text('Explore by category',
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final icon = cat['icon'] as IconData;
              final label = cat['label'] as String;
              final color = AppColors.badgeColors[i % AppColors.badgeColors.length];
              return GestureDetector(
                onTap: () => _onCategoryTap(label),
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(height: 6),
                      Text(label,
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        itemCount: _filterTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => _onTabSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.divider),
              ),
              child: Text(_filterTabs[i],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : AppColors.textSecondary,
                )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobList(JobProvider jobs) {
    if (jobs.jobs.isEmpty && jobs.loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (jobs.jobs.isEmpty && !jobs.loading) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.work_off_outlined,
                  size: 56, color: AppColors.textMuted.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text('No jobs found',
                style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Try adjusting your filters',
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...List.generate(jobs.jobs.length, (i) {
            final job = jobs.jobs[i];
            // Mark every 3rd card as "featured" for visual variety
            return JobCard(
              job: job,
              featured: i % 3 == 0,
              onTap: () {
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
          }),
          if (jobs.hasMore)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
            ),
        ],
      ),
    );
  }
}
