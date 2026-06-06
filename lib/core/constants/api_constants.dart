import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // ─── HOW TO RUN ────────────────────────────────────────────────────────────
  //
  //  Flutter Web (Chrome):
  //    flutter run -d chrome --web-port 3000
  //    Backend URL used: http://localhost:8080
  //
  //  Android Emulator:
  //    flutter run
  //    Backend URL used: http://10.0.2.2:8080
  //    (10.0.2.2 is the Android emulator's alias for your host machine's localhost)
  //
  //  Physical Android Device (USB):
  //    1. Find your PC's LAN IP (run `ipconfig` on Windows, look for IPv4)
  //    2. Replace physicalDeviceIp below with that IP
  //    3. Uncomment the physical device line in baseUrl getter
  //
  // ───────────────────────────────────────────────────────────────────────────

  // Physical device: replace with your PC's LAN IP (run `ipconfig` to find it)
  // then swap the return statement in baseUrl below.
  // static const String _physicalDeviceIp = '192.168.1.5';

  static String get baseUrl {
    if (kIsWeb) {
      // Flutter web runs in the browser — backend is on the same machine
      return 'http://localhost:8080';
    }
    // Android emulator — 10.0.2.2 maps to your host machine's localhost
    return 'http://10.0.2.2:8080';
    // Physical device — uncomment below and comment the line above:
    // return 'http://192.168.1.5:8080';
  }

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
