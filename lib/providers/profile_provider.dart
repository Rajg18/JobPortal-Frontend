import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../data/models/profile_model.dart';
import '../data/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;
  ProfileProvider(String token) : _service = ProfileService(token);

  ProfileModel? _profile;
  bool    _loading       = false;
  bool    _uploading     = false;
  String? _error;
  String? _uploadMessage;

  ProfileModel? get profile       => _profile;
  bool          get loading       => _loading;
  bool          get uploading     => _uploading;
  String?       get error         => _error;
  String?       get uploadMessage => _uploadMessage;

  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      _profile = await _service.getProfile();
      _error   = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProfile({
    required String skills,
    required String location,
    required String phone,
    required int    experience,
  }) async {
    _setLoading(true);
    try {
      _profile = await _service.saveProfile(
        skills: skills, location: location,
        phone: phone,   experience: experience,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadResume(Uint8List bytes, String fileName) async {
    _uploading     = true;
    _uploadMessage = null;
    _error         = null;
    notifyListeners();
    try {
      final msg = await _service.uploadResume(bytes, fileName);
      _uploadMessage = msg;
      // Reload profile so resumeUploaded + parsedSkills update in UI
      await _service.getProfile().then((p) => _profile = p);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }

  // Poll until parsedSkills is populated (AI parsing is async on backend)
  Future<void> pollUntilParsed({int maxAttempts = 12}) async {
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final p = await _service.getProfile();
        _profile = p;
        notifyListeners();
        if (p.parsedSkills != null && p.parsedSkills!.isNotEmpty) return;
      } catch (_) {}
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
