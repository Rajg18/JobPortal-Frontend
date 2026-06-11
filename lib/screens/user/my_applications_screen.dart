import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/application_provider.dart';
import '../../widgets/status_badge.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});
  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Applied', 'Accepted', 'Rejected'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<ApplicationProvider>().loadMyApplications());
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<ApplicationProvider>();
    final w      = MediaQuery.of(context).size.width;
    final isWide = w > 900;
    final hPad   = isWide ? ((w - 1100) / 2).clamp(24.0, double.infinity) : 24.0;
    final pad    = EdgeInsets.symmetric(horizontal: hPad);

    // Derived counts — always live from provider data
    final all      = prov.myApplications;
    final accepted = all.where((a) => a.status.toUpperCase() == 'ACCEPTED').length;
    final rejected = all.where((a) => a.status.toUpperCase() == 'REJECTED').length;
    final pending  = all.where((a) =>
        a.status.toUpperCase() != 'ACCEPTED' &&
        a.status.toUpperCase() != 'REJECTED').length;

    final filtered = _filter == 'All'
        ? all
        : all.where((a) =>
            a.status.toUpperCase() == _filter.toUpperCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => prov.loadMyApplications(),
        child: CustomScrollView(
          slivers: [

            // ── App bar ──────────────────────────────────────────────────
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
                  Text('My Applications',
                    style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
                  const Spacer(),
                  // Live badge — total count
                  if (!prov.loading && all.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${all.length} total',
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                    ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Refresh',
                    child: GestureDetector(
                      onTap: () => prov.loadMyApplications(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: prov.loading
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary))
                            : const Icon(Icons.refresh_rounded,
                                size: 20, color: AppColors.textSecondary),
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
              child: Padding(
                padding: pad.add(const EdgeInsets.only(top: 28)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Stats cards — skeleton when loading, real data when done ──
                    prov.loading && all.isEmpty
                        ? _statsSkeletonRow()
                        : _statsRow(all.length, accepted, rejected, pending),

                    const SizedBox(height: 24),

                    // ── Filter tabs ────────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((f) {
                          final sel = _filter == f;
                          final count = _countForFilter(f, all.length,
                              accepted, rejected, pending);
                          return GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.divider),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(f,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: sel
                                          ? AppColors.primary
                                          : AppColors.textSecondary)),
                                  if (count > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: sel
                                            ? AppColors.primary.withValues(alpha: 0.2)
                                            : AppColors.divider,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text('$count',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: sel
                                              ? AppColors.primary
                                              : AppColors.textMuted)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── List ─────────────────────────────────────────────
                    if (prov.error != null)
                      _errorState(prov.error!)
                    else if (prov.loading && all.isEmpty)
                      _loadingList()
                    else if (filtered.isEmpty)
                      _emptyState()
                    else
                      ...filtered.map((app) => _appCard(app)),

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

  int _countForFilter(String f, int total, int acc, int rej, int pend) {
    return switch (f) {
      'All'      => total,
      'Accepted' => acc,
      'Rejected' => rej,
      _          => pend, // Applied / Pending
    };
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _statsRow(int total, int accepted, int rejected, int pending) {
    return Row(children: [
      _statCard('Total',    total,    AppColors.primary, Icons.inbox_outlined),
      const SizedBox(width: 12),
      _statCard('Accepted', accepted, AppColors.success, Icons.check_circle_outline_rounded),
      const SizedBox(width: 12),
      _statCard('Rejected', rejected, AppColors.error,   Icons.cancel_outlined),
      const SizedBox(width: 12),
      _statCard('Pending',  pending,  AppColors.warning,  Icons.schedule_rounded),
    ]);
  }

  Widget _statCard(String label, int count, Color color, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(height: 12),
              Text('$count',
                style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );

  // Skeleton placeholder cards while loading
  Widget _statsSkeletonRow() {
    return Row(
      children: List.generate(4, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 3 ? 12 : 0),
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: const _Shimmer(),
        ),
      )),
    );
  }

  // ── Application card ───────────────────────────────────────────────────────
  Widget _appCard(dynamic app) {
    final badgeColor = AppColors.badgeFor(app.companyName);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        // Company badge
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              app.companyName.isNotEmpty
                  ? app.companyName[0].toUpperCase() : '?',
              style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: Colors.white)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(app.jobTitle,
                style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(app.companyName,
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 11, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(_formatDate(app.appliedAt),
                  style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textMuted)),
              ]),
            ],
          ),
        ),
        const SizedBox(width: 12),
        StatusBadge(status: app.status),
      ]),
    );
  }

  Widget _loadingList() => Column(
    children: List.generate(3, (i) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 86,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const _Shimmer(),
    )),
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 70),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface, shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(Icons.inbox_outlined,
              size: 32, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Text('No applications yet',
          style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text('Browse open jobs and hit Apply to get started',
          style: GoogleFonts.inter(
            fontSize: 13, color: AppColors.textMuted)),
      ]),
    ),
  );

  Widget _errorState(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded,
            size: 36, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Text(msg,
          style: GoogleFonts.inter(
            fontSize: 13, color: AppColors.textSecondary),
          textAlign: TextAlign.center),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: () => context.read<ApplicationProvider>().loadMyApplications(),
          child: const Text('Retry'),
        ),
      ]),
    ),
  );

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const m  = ['Jan','Feb','Mar','Apr','May','Jun',
                   'Jul','Aug','Sep','Oct','Nov','Dec'];
      return 'Applied ${m[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) { return raw; }
  }
}

// ── Simple shimmer pulse animation ─────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  const _Shimmer();
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.3, end: 0.7).animate(_anim),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
