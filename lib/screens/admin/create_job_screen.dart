import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_model.dart';
import '../../providers/job_provider.dart';
import '../../widgets/app_text_field.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _locCtrl    = TextEditingController();
  final _techCtrl   = TextEditingController();
  final _compCtrl   = TextEditingController();
  final _expCtrl    = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _locCtrl.dispose();
    _techCtrl.dispose();  _compCtrl.dispose(); _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final job = JobModel(
      id: 0, createdAt: '', postedBy: '',
      title:              _titleCtrl.text.trim(),
      description:        _descCtrl.text.trim(),
      location:           _locCtrl.text.trim(),
      techStack:          _techCtrl.text.trim(),
      companyName:        _compCtrl.text.trim(),
      experienceRequired: int.tryParse(_expCtrl.text.trim()) ?? 0,
    );
    final ok = await context.read<JobProvider>().createJob(job);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted!'), backgroundColor: AppColors.success));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<JobProvider>().error ?? 'Failed to post job'),
          backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Job Details',
                style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Fill in the details for your job posting',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),

              const SizedBox(height: 24),

              AppTextField(
                controller: _titleCtrl,
                label:      'Job Title',
                hint:       'e.g. Flutter Developer',
                prefixIcon: Icons.work_outline,
                validator:  (v) => (v == null || v.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _compCtrl,
                label:      'Company Name',
                hint:       'e.g. Acme Corp',
                prefixIcon: Icons.business_outlined,
                validator:  (v) => (v == null || v.isEmpty) ? 'Company is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _locCtrl,
                label:      'Location',
                hint:       'e.g. Bangalore / Remote',
                prefixIcon: Icons.location_on_outlined,
                validator:  (v) => (v == null || v.isEmpty) ? 'Location is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _techCtrl,
                label:      'Tech Stack',
                hint:       'e.g. Flutter, Spring Boot, MySQL',
                prefixIcon: Icons.code,
                validator:  (v) => (v == null || v.isEmpty) ? 'Tech stack is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller:   _expCtrl,
                label:        'Years of Experience Required',
                hint:         '2',
                prefixIcon:   Icons.workspace_premium_outlined,
                keyboardType: TextInputType.number,
                validator:    (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _descCtrl,
                label:      'Job Description',
                hint:       'Describe the role, responsibilities, and expectations...',
                prefixIcon: Icons.description_outlined,
                maxLines:   5,
                validator:  (v) => (v == null || v.isEmpty) ? 'Description is required' : null,
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: jobs.loading ? null : _submit,
                icon: jobs.loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                    : const Icon(Icons.send_outlined, size: 18),
                label: const Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
