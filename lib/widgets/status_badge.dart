import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status.toUpperCase()) {
      'ACCEPTED' => (AppColors.success, AppColors.success.withValues(alpha: 0.12), 'Accepted'),
      'REJECTED' => (AppColors.error,   AppColors.error.withValues(alpha: 0.12),   'Rejected'),
      'APPLIED'  => (AppColors.info,    AppColors.info.withValues(alpha: 0.12),    'Applied'),
      _          => (AppColors.warning,  AppColors.warning.withValues(alpha: 0.12), 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
