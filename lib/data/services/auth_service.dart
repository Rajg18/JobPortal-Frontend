import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthService {
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name':     name,
          'email':    email,
          'password': password,
          'roles':    role,
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) return res.body;
      throw Exception(_extractError(res));
    } on SocketException {
      throw Exception('Cannot reach server. Make sure your backend is running.');
    } on HttpException {
      throw Exception('Network error. Check your connection.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['token'] as String;
      }
      throw Exception(_extractError(res));
    } on SocketException {
      throw Exception('Cannot reach server. Make sure your backend is running.');
    } on HttpException {
      throw Exception('Network error. Check your connection.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
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
