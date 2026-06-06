import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/application_model.dart';

class ApplicationService {
  final Map<String, String> _h;
  ApplicationService(String token)
      : _h = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

  Future<String> applyJob(int jobId) => _wrap(() async {
    final res = await http.post(Uri.parse('${ApiConstants.applyJob}/$jobId'), headers: _h)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return res.body;
    throw Exception(_extractError(res));
  });

  Future<List<ApplicationModel>> getMyApplications() => _wrap(() async {
    final res = await http.get(Uri.parse(ApiConstants.myApplications), headers: _h)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load applications');
  });

  Future<List<ApplicationModel>> getApplicantsForJob(int jobId) => _wrap(() async {
    final res = await http.get(Uri.parse('${ApiConstants.adminApplicants}/$jobId'), headers: _h)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load applicants');
  });

  Future<String> updateStatus(int appId, String status) => _wrap(() async {
    final res = await http.put(
      Uri.parse('${ApiConstants.adminUpdateApp}/$appId'),
      headers: _h,
      body: jsonEncode({'status': status}),
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return res.body;
    throw Exception(_extractError(res));
  });

  Future<T> _wrap<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  String _extractError(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['message'] as String? ?? res.body;
    } catch (_) {
      return res.body.isNotEmpty ? res.body : 'Request failed (${res.statusCode})';
    }
  }
}
