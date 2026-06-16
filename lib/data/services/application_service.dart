import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../core/errors/session_expired_exception.dart';
import '../../core/utils/api_client.dart';
import '../models/application_model.dart';

class ApplicationService {
  final ApiClient _client;
  ApplicationService(String token) : _client = ApiClient(token);

  Future<String> applyJob(int jobId) => _wrap(() async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.applyJob}/$jobId'),
      timeout: const Duration(seconds: 60),
    );
    if (res.statusCode == 200) return res.body;
    throw Exception(_extractError(res));
  });

  Future<List<ApplicationModel>> getMyApplications() => _wrap(() async {
    final res = await _client.get(
      Uri.parse(ApiConstants.myApplications),
      timeout: const Duration(seconds: 60),
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load applications');
  });

  Future<List<ApplicationModel>> getApplicantsForJob(int jobId) =>
      _wrap(() async {
    final res = await _client.get(
      Uri.parse('${ApiConstants.adminApplicants}/$jobId'),
      timeout: const Duration(seconds: 60),
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load applicants');
  });

  Future<String> updateStatus(int appId, String status) => _wrap(() async {
    final res = await _client.put(
      Uri.parse('${ApiConstants.adminUpdateApp}/$appId'),
      body: jsonEncode({'status': status}),
      timeout: const Duration(seconds: 60),
    );
    if (res.statusCode == 200) return res.body;
    throw Exception(_extractError(res));
  });

  Future<T> _wrap<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on SessionExpiredException {
      rethrow;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  String _extractError(dynamic res) {
    try {
      final body = jsonDecode(res.body as String) as Map<String, dynamic>;
      return body['message'] as String? ?? res.body as String;
    } catch (_) {
      return (res.body as String).isNotEmpty
          ? res.body as String
          : 'Request failed (${res.statusCode})';
    }
  }
}
