import 'package:flutter/foundation.dart';
import '../data/models/application_model.dart';
import '../data/services/application_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationService _service;
  ApplicationProvider(String token) : _service = ApplicationService(token);

  List<ApplicationModel> _myApplications = [];
  List<ApplicationModel> _jobApplicants  = [];
  bool    _loading = false;
  String? _error;

  List<ApplicationModel> get myApplications => _myApplications;
  List<ApplicationModel> get jobApplicants  => _jobApplicants;
  bool    get loading => _loading;
  String? get error   => _error;

  /// Returns true if the user has already applied to [jobId].
  /// Falls back to title+company match when jobId is absent in older responses.
  bool hasAppliedToJob(int jobId, {String? title, String? company}) {
    for (final a in _myApplications) {
      if (a.jobId != null && a.jobId == jobId) return true;
      if (a.jobId == null &&
          title   != null && company != null &&
          a.jobTitle.toLowerCase()    == title.toLowerCase() &&
          a.companyName.toLowerCase() == company.toLowerCase()) return true;
    }
    return false;
  }

  Future<void> loadMyApplications() async {
    _setLoading(true);
    try {
      _myApplications = await _service.getMyApplications();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> applyJob(int jobId) async {
    try {
      await _service.applyJob(jobId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<void> loadApplicants(int jobId) async {
    _setLoading(true);
    try {
      _jobApplicants = await _service.getApplicantsForJob(jobId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateStatus(int appId, String status) async {
    try {
      await _service.updateStatus(appId, status);
      final idx = _jobApplicants.indexWhere((a) => a.id == appId);
      if (idx != -1) {
        _jobApplicants[idx] = ApplicationModel(
          id:          _jobApplicants[idx].id,
          jobTitle:    _jobApplicants[idx].jobTitle,
          companyName: _jobApplicants[idx].companyName,
          status:      status,
          appliedAt:   _jobApplicants[idx].appliedAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
