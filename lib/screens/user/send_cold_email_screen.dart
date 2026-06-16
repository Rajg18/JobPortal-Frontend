import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../data/services/email_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';

class SendColdEmailScreen extends StatefulWidget {
  final JobModel job;
  const SendColdEmailScreen({super.key, required this.job});
  @override
  State<SendColdEmailScreen> createState() => _SendColdEmailScreenState();
}

class _SendColdEmailScreenState extends State<SendColdEmailScreen> {
  final _recruiterEmailCtrl = TextEditingController();
  final _recruiterNameCtrl  = TextEditingController();

  String? _generatedEmail;
  bool    _generating = false;
  bool    _sending    = false;
  bool    _sent       = false;
  String? _error;

  late EmailService _emailService;

  @override
  void initState() {
    super.initState();
    // Pre-fill the recruiter email from the job's postedBy field
    _recruiterEmailCtrl.text = widget.job.postedBy;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token ?? '';
      _emailService = EmailService(token);
      // Auto-generate preview on open
      _generatePreview();
    });
  }

  @override
  void dispose() {
    _recruiterEmailCtrl.dispose();
    _recruiterNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _generatePreview() async {
    setState(() { _generating = true; _error = null; });
    try {
      final email = await _emailService.generateColdEmail(
        jobId:         widget.job.id,
        recruiterName: _recruiterNameCtrl.text.trim().isEmpty
            ? 'Hiring Manager'
            : _recruiterNameCtrl.text.trim(),
      );
      setState(() => _generatedEmail = email);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _generating = false);
    }
  }

  Future<void> _send() async {
    final recruiterEmail = _recruiterEmailCtrl.text.trim();
    if (recruiterEmail.isEmpty || !recruiterEmail.contains('@')) {
      setState(() => _error = 'Please enter a valid recruiter email address.');
      return;
    }

    setState(() { _sending = true; _error = null; });
    try {
      await _emailService.sendColdEmail(
        jobId:          widget.job.id,
        recruiterEmail: recruiterEmail,
        recruiterName:  _recruiterNameCtrl.text.trim().isEmpty
            ? 'Hiring Manager'
            : _recruiterNameCtrl.text.trim(),
      );
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = AppColors.badgeFor(widget.job.companyName);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Send Cold Email',
          style: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: _sent ? _successView() : _formView(badgeColor),
    );
  }

  Widget _formView(Color badgeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Job info card ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.job.companyName.isNotEmpty
                        ? widget.job.companyName[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.job.title,
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
                  Text(widget.job.companyName,
                    style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
                ],
              )),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Recruiter fields ───────────────────────────────────────────────
          _sectionLabel('Recruiter Details'),
          const SizedBox(height: 4),
          Text(
            'The email is pre-filled with the recruiter who posted this job. '
            'Add a name to personalise the greeting.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _recruiterEmailCtrl,
            label:      'Recruiter Email',
            hint:       'recruiter@company.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _recruiterNameCtrl,
            label:      'Recruiter Name (optional)',
            hint:       'e.g. John — leave blank for "Hiring Manager"',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generating ? null : _generatePreview,
              icon: _generating
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_rounded, size: 16),
              label: Text(_generating ? 'Generating…' : 'Regenerate Email Preview'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.divider),
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),

          const SizedBox(height: 24),

          // ── Email preview ──────────────────────────────────────────────────
          _sectionLabel('Generated Email Preview'),
          const SizedBox(height: 4),
          Text(
            'This email was written by AI using your resume\'s tech stack. '
            'It will be sent as an in-app message with your resume attached.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          if (_generating)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text('AI is crafting your personalised cold email…',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ]),
              ),
            )
          else if (_generatedEmail != null)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(_generatedEmail!,
                    style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textPrimary,
                      height: 1.7)),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Tooltip(
                    message: 'Copy to clipboard',
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _generatedEmail!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email copied to clipboard')));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Icon(Icons.copy_rounded,
                            size: 14, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // ── Resume note ────────────────────────────────────────────────────
          if (_generatedEmail != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.attach_file_rounded,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 7),
                Text('Your resume will be attached automatically.',
                  style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.success)),
              ]),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.error))),
              ]),
            ),
          ],

          const SizedBox(height: 24),

          // ── Send button ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: (_sending || _generating || _generatedEmail == null)
                  ? null
                  : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _sending ? 'Sending…' : 'Send Email to Recruiter',
                style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'The recruiter will receive this as an in-app message with your resume attached.',
              style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textMuted),
              textAlign: TextAlign.center),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _successView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline_rounded,
              size: 36, color: AppColors.success),
        ),
        const SizedBox(height: 20),
        Text('Cold Email Sent!',
          style: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Text(
          'Your personalised email for "${widget.job.title}" at '
          '${widget.job.companyName} has been delivered to the recruiter '
          'as an in-app message with your resume attached.',
          style: GoogleFonts.inter(
            fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          textAlign: TextAlign.center),
        const SizedBox(height: 28),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Jobs'),
          ),
        ),
      ]),
    ),
  );

  Widget _sectionLabel(String label) => Text(label,
    style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: AppColors.textMuted, letterSpacing: 0.7));
}
