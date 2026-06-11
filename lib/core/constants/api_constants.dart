import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // ─── BACKEND DEPLOYMENT ────────────────────────────────────────────────────
  //
  //  Production (Render):
  //    https://jobportal-backend-z2pv.onrender.com
  //
  //  Local dev — Flutter Web (Chrome):
  //    flutter run -d chrome --web-port 3000
  //    Uncomment _localUrl and use it in baseUrl below.
  //
  //  Local dev — Android Emulator:
  //    flutter run
  //    10.0.2.2 is the Android emulator alias for host machine's localhost.
  //
  // ───────────────────────────────────────────────────────────────────────────

  static const String _productionUrl = 'https://jobportal-backend-z2pv.onrender.com';

  // Uncomment to switch to local development:
  // static const String _localWebUrl    = 'http://localhost:8080';
  // static const String _localAndroid   = 'http://10.0.2.2:8080';

  static String get baseUrl => _productionUrl;

  // ─── Endpoints ─────────────────────────────────────────────────────────────
  static String get register => '$baseUrl/auth/register';
  static String get login    => '$baseUrl/auth/login';

  static String get saveProfile => '$baseUrl/api/profile/save';
  static String get getProfile  => '$baseUrl/api/profile/me';

  static String get jobs      => '$baseUrl/api/jobs';
  static String get adminJobs => '$baseUrl/api/jobs/admin';

  static String get applyJob        => '$baseUrl/api/applications/apply';
  static String get myApplications  => '$baseUrl/api/applications/my';
  static String get adminApplicants => '$baseUrl/api/applications/admin/job';
  static String get adminUpdateApp  => '$baseUrl/api/applications/admin';

  static String get adminStats => '$baseUrl/api/admin/stats';
}
