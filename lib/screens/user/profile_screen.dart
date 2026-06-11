import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_text_field.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack; // navigates back to the Jobs tab
  const ProfileScreen({super.key, this.onBack});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _skillsCtrl   = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _expCtrl      = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileProvider>().loadProfile();
      _prefill();
    });
  }

  void _prefill() {
    final p = context.read<ProfileProvider>().profile;
    if (p != null) {
      _skillsCtrl.text   = p.skills;
      _locationCtrl.text = p.location;
      _phoneCtrl.text    = p.phone;
      _expCtrl.text      = '${p.experience}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<ProfileProvider>().saveProfile(
      skills:     _skillsCtrl.text.trim(),
      location:   _locationCtrl.text.trim(),
      phone:      _phoneCtrl.text.trim(),
      experience: int.tryParse(_expCtrl.text.trim()) ?? 0,
    );
    if (!mounted) return;
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(ok
        ? const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: AppColors.success)
        : SnackBar(
            content: Text(
                context.read<ProfileProvider>().error ?? 'Save failed'),
            backgroundColor: AppColors.error));
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  void dispose() {
    _skillsCtrl.dispose(); _locationCtrl.dispose();
    _phoneCtrl.dispose(); _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final auth    = context.watch<AuthProvider>();
    final w       = MediaQuery.of(context).size.width;
    final isWide  = w > 900;
    final hPad    = isWide ? ((w - 1100) / 2).clamp(24.0, double.infinity) : 24.0;
    final pad     = EdgeInsets.symmetric(horizontal: hPad);

    final email    = auth.email ?? '';
    final initials = email.isNotEmpty ? email[0].toUpperCase() : 'U';
    final username = email.contains('@') ? email.split('@').first : email;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profile.loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2))
          : CustomScrollView(slivers: [

              // ── App bar ────────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 64,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: pad,
                  child: Row(children: [
                    // Back to Jobs
                    if (widget.onBack != null) ...[
                      _iconBtn(Icons.arrow_back_rounded, 'Back to Jobs',
                          widget.onBack!),
                      const SizedBox(width: 8),
                    ],
                    Text('My Profile',
                      style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                    const Spacer(),
                    if (!_editing)
                      _iconBtn(Icons.edit_outlined, 'Edit profile',
                          () => setState(() => _editing = true)),
                    const SizedBox(width: 4),
                    _iconBtn(Icons.logout_rounded, 'Sign out', _logout,
                        color: AppColors.error),
                  ]),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: AppColors.divider),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: pad.add(const EdgeInsets.symmetric(vertical: 32)),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left — avatar card
                            SizedBox(
                              width: 260,
                              child: _avatarCard(initials, username, email)),
                            const SizedBox(width: 24),
                            // Right — info / edit
                            Expanded(child: _contentCard(profile, username)),
                          ],
                        )
                      : Column(children: [
                          _avatarCard(initials, username, email),
                          const SizedBox(height: 20),
                          _contentCard(profile, username),
                        ]),
                ),
              ),
            ]),
    );
  }

  // ── Avatar card ─────────────────────────────────────────────────────────────
  Widget _avatarCard(String initials, String username, String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: [
        // Avatar circle
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(initials,
              style: GoogleFonts.inter(
                fontSize: 32, fontWeight: FontWeight.w800,
                color: const Color(0xFF0D0F12))),
          ),
        ),
        const SizedBox(height: 14),
        Text(username,
          style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(email,
          style: GoogleFonts.inter(
            fontSize: 12, color: AppColors.textSecondary),
          textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Job Seeker',
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.primary)),
        ),
      ]),
    );
  }

  // ── Content card (view or edit) ─────────────────────────────────────────────
  Widget _contentCard(ProfileProvider profile, String username) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: _editing
          ? _editForm(profile)
          : _viewMode(profile, username),
    );
  }

  Widget _viewMode(ProfileProvider profile, String username) {
    final p = profile.profile;
    if (p == null) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.person_add_alt_outlined,
                size: 26, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Text('Profile not set up yet',
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Add your skills and experience to get matched with roles',
            style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: 180,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Set up profile'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Professional Info'),
        const SizedBox(height: 14),
        _infoRow(Icons.psychology_outlined,        'Skills',
            p.skills.isEmpty ? '—' : p.skills),
        _divider(),
        _infoRow(Icons.location_on_outlined,        'Location',
            p.location.isEmpty ? '—' : p.location),
        _divider(),
        _infoRow(Icons.phone_outlined,               'Phone',
            p.phone.isEmpty ? '—' : p.phone),
        _divider(),
        _infoRow(Icons.workspace_premium_outlined,   'Experience',
            '${p.experience} year${p.experience == 1 ? '' : 's'}'),
        const SizedBox(height: 20),

        // Skills chips
        if (p.skills.isNotEmpty) ...[
          _sectionLabel('Skills'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: p.skills
                .split(RegExp(r'[,|\s]+'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(s,
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label) => Text(label,
    style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: AppColors.textMuted, letterSpacing: 0.8));

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: 12),
      Text('$label  ',
        style: GoogleFonts.inter(
          fontSize: 13, color: AppColors.textMuted)),
      Expanded(
        child: Text(value,
          style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
          textAlign: TextAlign.end),
      ),
    ]),
  );

  Widget _divider() =>
      Divider(height: 1, color: AppColors.divider.withValues(alpha: 0.6));

  Widget _editForm(ProfileProvider profile) {
    final saving = profile.loading;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Edit Profile'),
          const SizedBox(height: 16),
          AppTextField(
            controller: _skillsCtrl,
            label:      'Skills',
            hint:       'e.g. Flutter, Java, SQL',
            prefixIcon: Icons.psychology_outlined,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _locationCtrl,
            label:      'Location',
            hint:       'e.g. Bangalore, India',
            prefixIcon: Icons.location_on_outlined,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller:   _phoneCtrl,
            label:        'Phone',
            hint:         '+91 9876543210',
            prefixIcon:   Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller:   _expCtrl,
            label:        'Years of Experience',
            hint:         '0',
            prefixIcon:   Icons.workspace_premium_outlined,
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0D0F12)))
                    : const Text('Save Profile'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => setState(() { _editing = false; _prefill(); }),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: AppColors.divider),
                foregroundColor: AppColors.textSecondary),
              child: const Text('Cancel'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap,
      {Color color = AppColors.textSecondary}) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      );
}
