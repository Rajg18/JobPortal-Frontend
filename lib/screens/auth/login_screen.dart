import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import 'register_screen.dart';
import '../user/user_shell.dart';
import '../admin/admin_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure      = true;
  bool  _showWarmup   = false; // shown after 8s of loading

  Timer? _warmupTimer;

  @override
  void dispose() {
    _warmupTimer?.cancel();
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // After 8 seconds of waiting, hint that the server is warming up
    _warmupTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _showWarmup = true);
    });

    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    _warmupTimer?.cancel();
    if (!mounted) return;
    setState(() => _showWarmup = false);

    if (ok) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => auth.role == 'ADMIN' ? const AdminShell() : const UserShell()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login failed'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 6)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final w    = MediaQuery.of(context).size.width;
    final isWide = w > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Left panel (dark hero, only on wide screens) ─────────────────
          if (isWide)
            Expanded(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('H',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('HireLoop',
                        style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                    ]),
                    const Spacer(),
                    Text('Find work that\nmoves you forward.',
                      style: GoogleFonts.inter(
                        fontSize: 36, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary, height: 1.2,
                        letterSpacing: -0.8)),
                    const SizedBox(height: 16),
                    Text('Join 32k+ professionals who found their\nnext role through HireLoop.',
                      style: GoogleFonts.inter(
                        fontSize: 15, color: AppColors.textSecondary, height: 1.6)),
                    const SizedBox(height: 40),
                    ...[
                      '✓  Senior roles only — no junior clutter',
                      '✓  Companies that reply within 48h',
                      '✓  Salary ranges shown upfront',
                    ].map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(s,
                            style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textSecondary)),
                        )),
                    const Spacer(),
                  ],
                ),
              ),
            ),

          // ── Right panel (form) ────────────────────────────────────────────
          SizedBox(
            width: isWide ? 480 : w,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isWide) ...[
                      Row(children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('H',
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('HireLoop',
                          style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                      ]),
                      const SizedBox(height: 32),
                    ],
                    Text('Welcome back',
                      style: GoogleFonts.inter(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, letterSpacing: -0.4)),
                    const SizedBox(height: 4),
                    Text('Sign in to your account to continue',
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            controller:   _emailCtrl,
                            label:        'Email',
                            hint:         'you@example.com',
                            prefixIcon:   Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Email is required' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller:  _passCtrl,
                            label:       'Password',
                            prefixIcon:  Icons.lock_outline,
                            obscureText: _obscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted, size: 18),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Password is required' : null,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity, height: 46,
                            child: ElevatedButton(
                              onPressed: auth.loading ? null : _submit,
                              child: auth.loading
                                  ? const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text('Sign In'),
                            ),
                          ),
                          if (_showWarmup) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.warning.withValues(alpha: 0.3)),
                              ),
                              child: Row(children: [
                                SizedBox(
                                  width: 14, height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.warning),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Server is waking up on Render free tier — this can take up to 60s on the first request.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.warning,
                                      height: 1.4),
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                          style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textMuted)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Don't have an account?  ",
                            style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen())),
                            child: Text('Create account',
                              style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
