import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/utils/api_client.dart';
import '../core/utils/storage_service.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  String? _token;
  String? _role;
  String? _email;
  bool    _loading        = false;
  String? _error;
  bool    _sessionExpired = false;

  String? get token          => _token;
  String? get role           => _role;
  String? get email          => _email;
  bool    get loading        => _loading;
  String? get error          => _error;
  bool    get isLoggedIn     => _token != null;
  bool    get sessionExpired => _sessionExpired;

  // Called on app startup — restore session from storage.
  // Clears storage immediately if the stored token has already expired.
  Future<void> restoreSession() async {
    final token = await StorageService.getToken();
    if (token != null && ApiClient.isTokenExpired(token)) {
      await StorageService.clear();
      notifyListeners();
      return;
    }
    _token = token;
    _role  = await StorageService.getRole();
    _email = await StorageService.getEmail();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final token = await _service.login(email: email, password: password);
      final role  = _decodeRole(token);
      await StorageService.saveAuth(token: token, role: role, email: email);
      _token          = token;
      _role           = role;
      _email          = email;
      _error          = null;
      _sessionExpired = false;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    try {
      await _service.register(name: name, email: email, password: password, role: role);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout({bool expired = false}) async {
    await StorageService.clear();
    _token          = null;
    _role           = null;
    _email          = null;
    _sessionExpired = expired;
    notifyListeners();
  }

  // Decode the role claim from the JWT payload (no library needed).
  String _decodeRole(String token) {
    try {
      final parts   = token.split('.');
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map     = jsonDecode(payload) as Map<String, dynamic>;
      // Backend embeds roles as a comma-separated claim, e.g. "ADMIN" or "USER"
      final roles   = map['roles'] as String? ?? map['role'] as String? ?? 'USER';
      return roles.contains('ADMIN') ? 'ADMIN' : 'USER';
    } catch (_) {
      return 'USER';
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
