import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/stats_model.dart';

class AdminService {
  final Map<String, String> _h;
  AdminService(String token) : _h = {'Authorization': 'Bearer $token'};

  Future<StatsModel> getStats() async {
    try {
      final res = await http.get(Uri.parse(ApiConstants.adminStats), headers: _h)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) return StatsModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      throw Exception('Failed to load stats (${res.statusCode})');
    } on SocketException {
      throw Exception('Cannot reach server. Check your connection.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }
}
