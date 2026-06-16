import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../core/errors/session_expired_exception.dart';
import '../../core/utils/api_client.dart';
import '../models/message_model.dart';

class EmailService {
  final ApiClient _client;
  EmailService(String token) : _client = ApiClient(token);

  // Preview only — returns the generated email text without delivering it
  Future<String> generateColdEmail({
    required int    jobId,
    required String recruiterName,
  }) => _wrap(() async {
    final res = await _client.post(
      Uri.parse(ApiConstants.generateEmail),
      body: jsonEncode({'jobId': jobId, 'recruiterName': recruiterName}),
      timeout: const Duration(seconds: 45),
    );
    if (res.statusCode == 200) return res.body;
    throw Exception(_extractError(res));
  });

  // One-click: generate + deliver as in-app message with resume attached
  Future<MessageModel> sendColdEmail({
    required int    jobId,
    required String recruiterEmail,
    required String recruiterName,
  }) => _wrap(() async {
    final res = await _client.post(
      Uri.parse(ApiConstants.sendEmail),
      body: jsonEncode({
        'jobId':          jobId,
        'recruiterEmail': recruiterEmail,
        'recruiterName':  recruiterName,
      }),
      timeout: const Duration(seconds: 45),
    );
    if (res.statusCode == 200) {
      return MessageModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception(_extractError(res));
  });

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
}
