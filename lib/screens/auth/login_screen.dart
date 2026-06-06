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
  bool  _obscure   = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) =>
            auth.role == 'ADMIN' ? const AdminShell() : const UserShell(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login failed'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      // ── Gradient background ────────────────────────────────────────────────
      body: Container(
        width:  double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [
              Color(0xFF060F1E), // very dark navy
              Color(0xFF0A1628), // deep navy
              Color(0xFF0D1F3A), // slightly warmer navy
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width > 600 ? size.width * 0.2 : 24,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo mark (above card) ───────────────────────────────
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, AppColors.goldLight],
                        begin:  Alignment.topLeft,
                        end:    Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color:        AppColors.gold.withValues(alpha: 0.35),
                          blurRadius:   24,
                          spreadRadius: 0,
                          offset:       const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.work_outline_rounded,
                        color: AppColors.background, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text('JobPortal',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    )),
                  const SizedBox(height: 4),
                  Text('Your career starts here',
                    style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textMuted)),

                  const SizedBox(height: 32),

                  // ── Floating card ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color:  AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.8)),
                      boxShadow: [
                        BoxShadow(
                          color:       Colors.black.withValues(alpha: 0.4),
                          blurRadius:  40,
                          spreadRadius: 0,
                          offset:      const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Welcome back',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            )),
                          const SizedBox(height: 2),
                          Text('Sign in to your account',
                            style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textMuted)),

                          const SizedBox(height: 24),

                          AppTextField(
                            controller:   _emailCtrl,
                            label:        'Email',
                            hint:         'you@example.com',
                            prefixIcon:   Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator:    (v) =>
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
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Password is required' : null,
                          ),

                          const SizedBox(height: 24),

                          // Sign-in button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              ),
                              child: auth.loading
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.background))
                                  : const Text('Sign In'),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Row(children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or',
                                style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.textMuted)),
                            ),
                            const Expanded(child: Divider()),
                          ]),

                          const SizedBox(height: 16),

                          // Register link
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Don't have an account? ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                                GestureDetector(
                                  onTap: () => Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterScreen())),
                                  child: Text('Register',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ───────────────────────────────────────────────
                  Text('Secure · Fast · Professional',
                    style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textMuted,
                      letterSpacing: 1.2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
