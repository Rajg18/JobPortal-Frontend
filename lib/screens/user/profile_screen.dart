import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_text_field.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _skillsCtrl  = TextEditingController();
  final _locationCtrl= TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _expCtrl     = TextEditingController();
  bool  _editing     = false;

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
    ScaffoldMessenger.of(context).showSnackBar(
      ok
          ? const SnackBar(content: Text('Profile saved!'), backgroundColor: AppColors.success)
          : SnackBar(
              content: Text(context.read<ProfileProvider>().error ?? 'Save failed'),
              backgroundColor: AppColors.error),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  void dispose() {
    _skillsCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final auth    = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Profile'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => setState(() => _editing = true),
            ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: AppColors.error),
            onPressed: _logout,
          ),
        ],
      ),
      body: profile.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // â”€â”€ Avatar card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.gold, AppColors.goldLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (auth.email ?? 'U')[0].toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 32, fontWeight: FontWeight.w800,
                                color: AppColors.background),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(auth.email ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color:        AppColors.skyBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Job Seeker',
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppColors.skyBlue)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  if (_editing)
                    _editForm()
                  else
                    _viewCard(profile),
                ],
              ),
            ),
    );
  }

  Widget _viewCard(ProfileProvider profile) {
    final p = profile.profile;
    if (p == null) {
      return Column(
        children: [
          const Icon(Icons.person_add_alt_outlined, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Profile not set up yet',
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() => _editing = true),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Profile'),
          ),
        ],
      );
    }
    return Column(
      children: [
        _infoTile(Icons.psychology_outlined,    'Skills',      p.skills),
        _infoTile(Icons.location_on_outlined,   'Location',    p.location),
        _infoTile(Icons.phone_outlined,          'Phone',       p.phone),
        _infoTile(Icons.workspace_premium_outlined, 'Experience', '${p.experience} years'),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              Text(value,
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editForm() {
    final saving = context.watch<ProfileProvider>().loading;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _skillsCtrl,
            label:      'Skills',
            hint:       'e.g. Flutter, Java, SQL',
            prefixIcon: Icons.psychology_outlined,
            validator:  (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _locationCtrl,
            label:      'Location',
            hint:       'e.g. Bangalore',
            prefixIcon: Icons.location_on_outlined,
            validator:  (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller:   _phoneCtrl,
            label:        'Phone',
            hint:         '+91 9876543210',
            prefixIcon:   Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator:    (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller:   _expCtrl,
            label:        'Years of Experience',
            hint:         '0',
            prefixIcon:   Icons.workspace_premium_outlined,
            keyboardType: TextInputType.number,
            validator:    (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                : const Text('Save Profile'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() { _editing = false; _prefill(); }),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
