import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../core/errors/session_expired_exception.dart';
import '../../core/utils/api_client.dart';
import '../models/job_model.dart';

class JobService {
  final ApiClient _client;
  JobService(String token) : _client = ApiClient(token);

  Future<List<JobModel>> searchJobs({
    String? location,
    String? techStack,
    String? companyName,
    int?    experience,
    String? postedBy,
    int page = 0,
    int size = 10,
  }) async {
    final params = <String, String>{'page': '$page', 'size': '$size'};
    if (location    != null && location.isNotEmpty)    params['location']    = location;
    if (techStack   != null && techStack.isNotEmpty)   params['techStack']   = techStack;
    if (companyName != null && companyName.isNotEmpty) params['companyName'] = companyName;
    if (experience  != null)                           params['experience']  = '$experience';
    if (postedBy    != null && postedBy.isNotEmpty)    params['postedBy']    = postedBy;

    final uri = Uri.parse(ApiConstants.jobs).replace(queryParameters: params);
    return _wrap(() async {
      final res = await _client.get(uri,
          timeout: const Duration(seconds: 60));
      if (res.statusCode == 200) {
        final data    = jsonDecode(res.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>;
        return content
            .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load jobs (${res.statusCode})');
    });
  }

  Future<JobModel> getJob(int id) => _wrap(() async {
    final res = await _client.get(
      Uri.parse('${ApiConstants.jobs}/$id'),
      timeout: const Duration(seconds: 60),
    );
    if (res.statusCode == 200) {
      return JobModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Job not found');
  });

  Future<JobModel> createJob(JobModel job) => _wrap(() async {
    final res = await _client.post(
      Uri.parse(ApiConstants.adminJobs),
      body: jsonEncode(job.toJson()),
      timeout: const Duration(seconds: 60),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return JobModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create job');
  });

  Future<void> deleteJob(int id) => _wrap(() async {
    final res = await _client.delete(
      Uri.parse('${ApiConstants.adminJobs}/$id'),
      timeout: const Duration(seconds: 60),
    );
    if (res.statusCode != 200) throw Exception('Failed to delete job');
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
}
