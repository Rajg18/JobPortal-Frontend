import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/session_expired_exception.dart';

/// Thin HTTP wrapper that:
///  • attaches the Bearer token on every request
///  • throws [SessionExpiredException] on any 401 response
///  • exposes [isTokenExpired] so callers can check before sending
///
/// [onSessionExpired] is a global callback registered once from main.dart.
/// It triggers [AuthProvider.logout] without coupling this class to any provider.
class ApiClient {
  final Map<String, String> _headers;

  // Registered in main.dart so services can trigger global logout without
  // importing AuthProvider (avoids core→provider layer violation).
  static void Function()? onSessionExpired;

  ApiClient(String token)
      : _headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        };

  // ─── Token expiry check ────────────────────────────────────────────────────

  /// Returns true if the JWT [token]'s `exp` claim is in the past.
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final exp = map['exp'] as int?;
      if (exp == null) return false;
      return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(exp * 1000),
      );
    } catch (_) {
      return true;
    }
  }

  // ─── HTTP verbs ────────────────────────────────────────────────────────────

  Future<http.Response> get(
    Uri uri, {
    Duration timeout = const Duration(seconds: 60),
  }) =>
      _execute(() => http.get(uri, headers: _headers).timeout(timeout));

  Future<http.Response> post(
    Uri uri, {
    Object? body,
    Duration timeout = const Duration(seconds: 60),
  }) =>
      _execute(
        () => http.post(uri, headers: _headers, body: body).timeout(timeout),
      );

  Future<http.Response> put(
    Uri uri, {
    Object? body,
    Duration timeout = const Duration(seconds: 60),
  }) =>
      _execute(
        () => http.put(uri, headers: _headers, body: body).timeout(timeout),
      );

  Future<http.Response> patch(
    Uri uri, {
    Object? body,
    Duration timeout = const Duration(seconds: 60),
  }) =>
      _execute(
        () => http.patch(uri, headers: _headers, body: body).timeout(timeout),
      );

  Future<http.Response> delete(
    Uri uri, {
    Duration timeout = const Duration(seconds: 60),
  }) =>
      _execute(() => http.delete(uri, headers: _headers).timeout(timeout));

  // ─── Internal ──────────────────────────────────────────────────────────────

  Future<http.Response> _execute(
    Future<http.Response> Function() call,
  ) async {
    final res = await call();
    if (res.statusCode == 401) {
      onSessionExpired?.call(); // triggers AuthProvider.logout() globally
      throw const SessionExpiredException();
    }
    return res;
  }
}
