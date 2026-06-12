import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // ───────────────────────────────────────────────────────────────────────────
  // Production Backend (Render)
  // ───────────────────────────────────────────────────────────────────────────
  static const String _productionUrl =
      'https://jobportal-backend-z2pv.onrender.com';

  // ───────────────────────────────────────────────────────────────────────────
  // Local Development URLs
  // ───────────────────────────────────────────────────────────────────────────
  static const String _localWebUrl = 'http://localhost:8080';
  static const String _localAndroidUrl = 'http://10.0.2.2:8080';

  // ───────────────────────────────────────────────────────────────────────────
  // Current Base URL
  // Change this back to local URLs only when developing locally.
  // ───────────────────────────────────────────────────────────────────────────
  static String get baseUrl => _productionUrl;

  // ───────────────────────────────────────────────────────────────────────────
  // Authentication
  // ───────────────────────────────────────────────────────────────────────────
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';

  // ───────────────────────────────────────────────────────────────────────────
  // Profile
  // ───────────────────────────────────────────────────────────────────────────
  static String get saveProfile => '$baseUrl/api/profile/save';
  static String get getProfile => '$baseUrl/api/profile/me';

  // ───────────────────────────────────────────────────────────────────────────
  // Jobs
  // ───────────────────────────────────────────────────────────────────────────
  static String get jobs => '$baseUrl/api/jobs';
  static String get adminJobs => '$baseUrl/api/jobs/admin';

  // ───────────────────────────────────────────────────────────────────────────
  // Applications
  // ───────────────────────────────────────────────────────────────────────────
  static String get applyJob => '$baseUrl/api/applications/apply';
  static String get myApplications => '$baseUrl/api/applications/my';
  static String get adminApplicants => '$baseUrl/api/applications/admin/job';
  static String get adminUpdateApp => '$baseUrl/api/applications/admin';

  // ───────────────────────────────────────────────────────────────────────────
  // Admin Dashboard
  // ───────────────────────────────────────────────────────────────────────────
  static String get adminStats => '$baseUrl/api/admin/stats';
}
