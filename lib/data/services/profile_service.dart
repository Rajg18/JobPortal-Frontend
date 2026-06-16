import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/session_expired_exception.dart';
import '../../core/utils/api_client.dart';
import '../models/profile_model.dart';

class ProfileService {
  final ApiClient _client;
  final String _token;
  ProfileService(String token) : _client = ApiClient(token), _token = token;

  Future<ProfileModel> getProfile() => _wrap(() async {
    final res = await _client.get(Uri.parse(ApiConstants.getProfile));
    if (res.statusCode == 200) {
      return ProfileModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Profile not found');
  });

  Future<ProfileModel> saveProfile({
    required String skills,
    required String location,
    required String phone,
    required int    experience,
  }) => _wrap(() async {
    final res = await _client.post(
      Uri.parse(ApiConstants.saveProfile),
      body: jsonEncode({
        'skills': skills, 'location': location,
        'phone': phone,   'experience': experience,
      }),
    );
    if (res.statusCode == 200) {
      return ProfileModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to save profile');
  });

  // Upload PDF resume as multipart form-data → POST /api/profile/resume
  Future<String> uploadResume(Uint8List fileBytes, String fileName) =>
      _wrap(() async {
    final uri     = Uri.parse(ApiConstants.uploadResume);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_token'
      ..files.add(http.MultipartFile.fromBytes(
        'file', fileBytes,
        filename: fileName,
      ));

    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final res      = await http.Response.fromStream(streamed);

    if (res.statusCode == 401) {
      ApiClient.onSessionExpired?.call();
      throw const SessionExpiredException();
    }
    if (res.statusCode == 200 || res.statusCode == 202) return res.body;
    throw Exception('Upload failed (${res.statusCode}): ${res.body}');
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
