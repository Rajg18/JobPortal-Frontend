import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthService {
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name':     name,
        'email':    email,
        'password': password,
        'roles':    role,
      }),
    ).timeout(const Duration(seconds: 60),
        onTimeout: () => throw Exception(
            'Request timed out. The server may be waking up — please try again.'));

    if (res.statusCode == 200 || res.statusCode == 201) return res.body;
    throw Exception(_extractError(res));
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    ).timeout(const Duration(seconds: 60),
        onTimeout: () => throw Exception(
            'Request timed out. The server may be waking up — please try again.'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['token'] as String;
    }
    throw Exception(_extractError(res));
  }

  String _extractError(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['message'] as String?
          ?? body['error'] as String?
          ?? body['detail'] as String?
          ?? res.body;
    } catch (_) {
      return res.body.isNotEmpty
          ? res.body
          : 'Request failed (${res.statusCode})';
    }
  }
}
