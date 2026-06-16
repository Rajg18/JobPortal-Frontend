import 'package:flutter/foundation.dart';
import '../data/models/message_model.dart';
import '../data/services/message_service.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _service;
  MessageProvider(String token) : _service = MessageService(token);

  List<MessageModel> _inbox   = [];
  List<MessageModel> _sent    = [];
  bool    _loading = false;
  String? _error;

  List<MessageModel> get inbox   => _inbox;
  List<MessageModel> get sent    => _sent;
  bool    get loading => _loading;
  String? get error   => _error;

  int get unreadCount => _inbox.where((m) => !m.read).length;

  Future<void> loadInbox() async {
    _setLoading(true);
    try {
      _inbox = await _service.getInbox();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSent() async {
    _setLoading(true);
    try {
      _sent  = await _service.getSent();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<List<int>> downloadResume(int messageId) =>
      _service.downloadResume(messageId);

  Future<void> markAsRead(int messageId) async {
    try {
      final updated = await _service.markAsRead(messageId);
      final idx = _inbox.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        _inbox[idx] = updated;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
