import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../core/errors/session_expired_exception.dart';
import '../../core/utils/api_client.dart';
import '../models/message_model.dart';

class MessageService {
  final ApiClient _client;
  MessageService(String token) : _client = ApiClient(token);

  Future<List<MessageModel>> getInbox() => _wrap(() async {
    final res = await _client.get(Uri.parse(ApiConstants.inbox));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load inbox');
  });

  Future<List<MessageModel>> getSent() => _wrap(() async {
    final res = await _client.get(Uri.parse(ApiConstants.sent));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load sent messages');
  });

  Future<MessageModel> markAsRead(int messageId) => _wrap(() async {
    final res = await _client.patch(Uri.parse(ApiConstants.messageRead(messageId)));
    if (res.statusCode == 200) {
      return MessageModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to mark as read');
  });

  Future<List<int>> downloadResume(int messageId) => _wrap(() async {
    final res = await _client.get(Uri.parse(ApiConstants.messageResume(messageId)));
    if (res.statusCode == 200) return res.bodyBytes;
    throw Exception('Resume not available');
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
