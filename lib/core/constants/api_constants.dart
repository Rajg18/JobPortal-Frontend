class ApiConstants {
  static const String _productionUrl = 'https://jobportal-backend-z2pv.onrender.com';
  static const String _localUrl      = 'http://localhost:8080';

  static String get baseUrl => _localUrl;

  // ── Auth ────────────────────────────────────────────────────────────────────
  static String get register => '$baseUrl/auth/register';
  static String get login    => '$baseUrl/auth/login';

  // ── Profile ─────────────────────────────────────────────────────────────────
  static String get saveProfile   => '$baseUrl/api/profile/save';
  static String get getProfile    => '$baseUrl/api/profile/me';
  static String get uploadResume  => '$baseUrl/api/profile/resume';

  // ── Jobs ────────────────────────────────────────────────────────────────────
  static String get jobs      => '$baseUrl/api/jobs';
  static String get adminJobs => '$baseUrl/api/jobs/admin';
  static String get matchJobs => '$baseUrl/api/jobs/match';

  // ── Applications ────────────────────────────────────────────────────────────
  static String get applyJob       => '$baseUrl/api/applications/apply';
  static String get myApplications => '$baseUrl/api/applications/my';
  static String get adminApplicants => '$baseUrl/api/applications/admin/job';
  static String get adminUpdateApp  => '$baseUrl/api/applications/admin';

  // ── Cold Email ──────────────────────────────────────────────────────────────
  static String get generateEmail => '$baseUrl/api/email/generate';
  static String get sendEmail     => '$baseUrl/api/email/send';

  // ── Messaging ───────────────────────────────────────────────────────────────
  static String get inbox => '$baseUrl/api/messages/inbox';
  static String get sent  => '$baseUrl/api/messages/sent';
  static String messageRead(int id)           => '$baseUrl/api/messages/$id/read';
  static String messageResume(int id)         => '$baseUrl/api/messages/$id/resume';

  // ── Admin Dashboard ─────────────────────────────────────────────────────────
  static String get adminStats => '$baseUrl/api/admin/stats';
}
