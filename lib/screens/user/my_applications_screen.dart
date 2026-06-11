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
    final apps   = context.watch<ApplicationProvider>();
    final w      = MediaQuery.of(context).size.width;
    final isWide = w > 900;
    final hPad   = isWide ? ((w - 1100) / 2).clamp(24.0, double.infinity) : 24.0;
    final pad    = EdgeInsets.symmetric(horizontal: hPad);

    final all      = apps.myApplications;
    final accepted = all.where((a) => a.status.toUpperCase() == 'ACCEPTED').length;
    final rejected = all.where((a) => a.status.toUpperCase() == 'REJECTED').length;
    final pending  = all.where((a) =>
        a.status.toUpperCase() != 'ACCEPTED' &&
        a.status.toUpperCase() != 'REJECTED').length;

    final filtered = _filter == 'All'
        ? all
        : all.where((a) => a.status.toUpperCase() == _filter.toUpperCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: apps.loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () => context.read<ApplicationProvider>().loadMyApplications(),
              child: CustomScrollView(
                slivers: [

                  // ── App bar ────────────────────────────────────────────────
                  SliverAppBar(
                    pinned: true,
                    floating: false,
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
                        Tooltip(
                          message: 'Refresh',
                          child: InkWell(
                            onTap: () => context
                                .read<ApplicationProvider>()
                                .loadMyApplications(),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.refresh_rounded,
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

                          // ── Stats row ──────────────────────────────────────
                          if (all.isNotEmpty) ...[
                            Row(children: [
                              _statCard('Total', all.length,
                                  AppColors.primary, Icons.inbox_outlined),
                              const SizedBox(width: 12),
                              _statCard('Accepted', accepted,
                                  AppColors.success, Icons.check_circle_outline_rounded),
                              const SizedBox(width: 12),
                              _statCard('Rejected', rejected,
                                  AppColors.error, Icons.cancel_outlined),
                              const SizedBox(width: 12),
                              _statCard('Pending', pending,
                                  AppColors.warning, Icons.schedule_rounded),
                            ]),
                            const SizedBox(height: 28),
                          ],

                          // ── Filter tabs ────────────────────────────────────
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filters.map((f) {
                                final sel = _filter == f;
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
                                    child: Text(f,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: sel
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: sel
                                            ? AppColors.primary
                                            : AppColors.textSecondary)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── List ───────────────────────────────────────────
                          if (filtered.isEmpty)
                            _emptyState()
                          else
                            ...filtered.map((app) => _appCard(app, isWide)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
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
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
              ]),
              const SizedBox(height: 12),
              Text('$count',
                style: GoogleFonts.inter(
                  fontSize: 24, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );

  Widget _appCard(app, bool isWide) {
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

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return 'Applied ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) { return raw; }
  }
}
