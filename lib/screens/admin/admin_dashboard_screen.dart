import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/stats_model.dart';
import '../../data/services/admin_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  StatsModel? _stats;
  bool        _loading = true;
  String?     _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = context.read<AuthProvider>().token ?? '';
      final stats = await AdminService(token).getStats();
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final email    = context.watch<AuthProvider>().email ?? '';
    final name     = email.contains('@') ? email.split('@').first : email;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Welcome banner ───────────────────────────────────
                        _welcomeBanner(initials, name, email),
                        const SizedBox(height: 24),

                        // ── Section label ────────────────────────────────────
                        _sectionLabel('My Recruitment Overview'),
                        const SizedBox(height: 12),

                        // ── 4 stat cards in a 2×2 grid ──────────────────────
                        Row(children: [
                          Expanded(child: _statCard(
                            'Jobs Posted',  '${_stats!.myJobs}',
                            Icons.work_rounded, AppColors.gold,
                            subtitle: 'by you')),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard(
                            'Total Applicants', '${_stats!.myApplications}',
                            Icons.people_alt_rounded, AppColors.skyBlue,
                            subtitle: 'on your jobs')),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _statCard(
                            'Accepted', '${_stats!.acceptedApplications}',
                            Icons.check_circle_rounded, AppColors.success,
                            subtitle: 'candidates')),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard(
                            'Pending', '${_stats!.pendingApplications}',
                            Icons.hourglass_top_rounded, AppColors.warning,
                            subtitle: 'awaiting review')),
                        ]),

                        const SizedBox(height: 24),

                        // ── Application funnel ───────────────────────────────
                        _sectionLabel('Application Funnel'),
                        const SizedBox(height: 12),
                        _funnelCard(),

                        const SizedBox(height: 24),

                        // ── Status breakdown bars ────────────────────────────
                        _sectionLabel('Status Breakdown'),
                        const SizedBox(height: 12),
                        _statusBreakdownCard(),

                        const SizedBox(height: 24),

                        // ── Platform context row ─────────────────────────────
                        _sectionLabel('Platform'),
                        const SizedBox(height: 12),
                        _platformCard(),

                        const SizedBox(height: 24),

                        // ── Quick tips ───────────────────────────────────────
                        _sectionLabel('Recruiter Tips'),
                        const SizedBox(height: 12),
                        _tipCard(
                          Icons.lightbulb_outline_rounded,
                          AppColors.gold,
                          'Review pending applications',
                          'You have ${_stats!.pendingApplications} application(s) waiting. '
                          'Timely responses improve candidate experience.',
                        ),
                        const SizedBox(height: 10),
                        _tipCard(
                          Icons.trending_up_rounded,
                          AppColors.skyBlue,
                          'Acceptance rate',
                          _stats!.myApplications > 0
                              ? '${((_stats!.acceptedApplications / _stats!.myApplications) * 100).toStringAsFixed(1)}% of applicants '
                                'have been accepted across your ${_stats!.myJobs} job posting(s).'
                              : 'Post jobs and review applications to see your acceptance rate.',
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Welcome banner ─────────────────────────────────────────────────────────
  Widget _welcomeBanner(String initials, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2F4A), Color(0xFF0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      AppColors.gold.withValues(alpha: 0.3),
                  blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Center(
              child: Text(initials,
                style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppColors.background)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good to see you, $name!',
                  style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(email,
                  style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _badge('RECRUITER', AppColors.gold),
                    const SizedBox(width: 6),
                    _badge('${_stats!.myJobs} Jobs Active', AppColors.skyBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color:        color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border:       Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(text,
      style: GoogleFonts.poppins(
        fontSize: 9, fontWeight: FontWeight.w700, color: color)),
  );

  // ── Stat card ──────────────────────────────────────────────────────────────
  Widget _statCard(String label, String value, IconData icon, Color color,
      {String subtitle = ''}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 9, color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
            style: GoogleFonts.poppins(
              fontSize: 26, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, height: 1)),
          const SizedBox(height: 4),
          Text(label,
            style: GoogleFonts.poppins(
              fontSize: 12, color: AppColors.textSecondary,
              fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Application funnel ─────────────────────────────────────────────────────
  Widget _funnelCard() {
    final total    = _stats!.myApplications;
    final accepted = _stats!.acceptedApplications;
    final rejected = _stats!.rejectedApplications;
    final pending  = _stats!.pendingApplications;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _funnelRow('Total Applications', total,   total,    AppColors.skyBlue),
          const SizedBox(height: 10),
          _funnelRow('Pending Review',     pending, total,    AppColors.warning),
          const SizedBox(height: 10),
          _funnelRow('Accepted',           accepted, total,   AppColors.success),
          const SizedBox(height: 10),
          _funnelRow('Rejected',           rejected, total,   AppColors.error),
        ],
      ),
    );
  }

  Widget _funnelRow(String label, int count, int total, Color color) {
    final pct   = total > 0 ? count / total : 0.0;
    final pctStr = total > 0
        ? '${(pct * 100).toStringAsFixed(0)}%'
        : '—';
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
            style: GoogleFonts.poppins(
              fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           pct,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor:      AlwaysStoppedAnimation<Color>(color),
              minHeight:       8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(pctStr,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  // ── Status breakdown card (3 columns) ─────────────────────────────────────
  Widget _statusBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(child: _breakdownCol(
            'Accepted', _stats!.acceptedApplications,
            _stats!.myApplications, AppColors.success)),
          _vertDivider(),
          Expanded(child: _breakdownCol(
            'Pending', _stats!.pendingApplications,
            _stats!.myApplications, AppColors.warning)),
          _vertDivider(),
          Expanded(child: _breakdownCol(
            'Rejected', _stats!.rejectedApplications,
            _stats!.myApplications, AppColors.error)),
        ],
      ),
    );
  }

  Widget _vertDivider() => Container(
    height: 60, width: 1, color: AppColors.divider,
    margin: const EdgeInsets.symmetric(horizontal: 8));

  Widget _breakdownCol(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Column(
      children: [
        Text('$count',
          style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text('$pct%',
          style: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.7))),
        const SizedBox(height: 4),
        Text(label,
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value:           total > 0 ? count / total : 0.0,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor:      AlwaysStoppedAnimation<Color>(color),
            minHeight:       5,
          ),
        ),
      ],
    );
  }

  // ── Platform context card ──────────────────────────────────────────────────
  Widget _platformCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        AppColors.skyBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.people_outline,
              color: AppColors.skyBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_stats!.totalUsers} registered job seekers',
                style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
              Text('active on the platform',
                style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tip card ──────────────────────────────────────────────────────────────
  Widget _tipCard(IconData icon, Color color, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 3),
                Text(body,
                  style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) => Text(label,
    style: GoogleFonts.poppins(
      fontSize: 13, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 0.5));

  // ── Error view ────────────────────────────────────────────────────────────
  Widget _errorView() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 56, color: AppColors.error),
        const SizedBox(height: 12),
        Text('Failed to load stats',
          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _load, child: const Text('Retry')),
      ],
    ),
  );
}
