import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

class ProfileService {
  final Map<String, String> _h;
  ProfileService(String token)
      : _h = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

  Future<ProfileModel> getProfile() => _wrap(() async {
    final res = await http.get(Uri.parse(ApiConstants.getProfile), headers: _h)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return ProfileModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    throw Exception('Profile not found');
  });

  Future<ProfileModel> saveProfile({
    required String skills,
    required String location,
    required String phone,
    required int experience,
  }) => _wrap(() async {
    final res = await http.post(
      Uri.parse(ApiConstants.saveProfile),
      headers: _h,
      body: jsonEncode({
        'skills':     skills,
        'location':   location,
        'phone':      phone,
        'experience': experience,
      }),
    ).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return ProfileModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    throw Exception('Failed to save profile');
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
