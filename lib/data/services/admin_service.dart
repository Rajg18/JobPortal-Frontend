import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/stats_model.dart';

class AdminService {
  final Map<String, String> _h;
  AdminService(String token) : _h = {'Authorization': 'Bearer $token'};

  Future<StatsModel> getStats() async {
    final res = await http.get(Uri.parse(ApiConstants.adminStats), headers: _h)
        .timeout(const Duration(seconds: 60),
            onTimeout: () => throw Exception('Timed out loading stats — server may be waking up.'));
    if (res.statusCode == 200) {
      return StatsModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load stats (${res.statusCode})');
  }
}
