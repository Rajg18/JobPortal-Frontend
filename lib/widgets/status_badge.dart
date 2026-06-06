import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status.toUpperCase()) {
      'ACCEPTED' => (AppColors.success,  AppColors.success.withValues(alpha: 0.15),  'Accepted'),
      'REJECTED' => (AppColors.error,    AppColors.error.withValues(alpha: 0.15),    'Rejected'),
      _          => (AppColors.warning,  AppColors.warning.withValues(alpha: 0.15),  'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
