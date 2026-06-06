import 'package:flutter/foundation.dart';
import '../data/models/profile_model.dart';
import '../data/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;
  ProfileProvider(String token) : _service = ProfileService(token);

  ProfileModel? _profile;
  bool    _loading = false;
  String? _error;

  ProfileModel? get profile => _profile;
  bool    get loading => _loading;
  String? get error   => _error;

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
        skills:     skills,
        location:   location,
        phone:      phone,
        experience: experience,
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

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
