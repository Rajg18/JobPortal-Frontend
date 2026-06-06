import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/job_model.dart';

class JobService {
  final Map<String, String> _h;
  JobService(String token)
      : _h = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

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
      final res = await http.get(uri, headers: _h).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data    = jsonDecode(res.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>;
        return content.map((e) => JobModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to load jobs (${res.statusCode})');
    });
  }

  Future<JobModel> getJob(int id) => _wrap(() async {
    final res = await http.get(Uri.parse('${ApiConstants.jobs}/$id'), headers: _h)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return JobModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    throw Exception('Job not found');
  });

  Future<JobModel> createJob(JobModel job) => _wrap(() async {
    final res = await http.post(Uri.parse(ApiConstants.adminJobs),
        headers: _h, body: jsonEncode(job.toJson()))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return JobModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    throw Exception('Failed to create job');
  });

  Future<void> deleteJob(int id) => _wrap(() async {
    final res = await http.delete(Uri.parse('${ApiConstants.adminJobs}/$id'), headers: _h)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Failed to delete job');
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
}
