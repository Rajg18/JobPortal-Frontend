import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../core/errors/session_expired_exception.dart';
import '../../core/utils/api_client.dart';
import '../models/stats_model.dart';

class AdminService {
  final ApiClient _client;
  AdminService(String token) : _client = ApiClient(token);

  Future<StatsModel> getStats() async {
    try {
      final res = await _client.get(
        Uri.parse(ApiConstants.adminStats),
        timeout: const Duration(seconds: 60),
      );
      if (res.statusCode == 200) {
        return StatsModel.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>);
      }
      throw Exception('Failed to load stats (${res.statusCode})');
    } on SessionExpiredException {
      rethrow;
    }
  }
}
