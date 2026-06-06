import 'package:flutter/foundation.dart';
import '../data/models/job_model.dart';
import '../data/services/job_service.dart';

class JobProvider extends ChangeNotifier {
  final JobService _service;

  // When [ownerEmail] is set, only jobs posted by that email are loaded.
  // Used by the admin portal so each recruiter only sees their own jobs.
  final String? ownerEmail;

  JobProvider(String token, {this.ownerEmail}) : _service = JobService(token);

  List<JobModel> _jobs    = [];
  bool           _loading = false;
  String?        _error;
  bool           _hasMore = true;
  int            _page    = 0;

  List<JobModel> get jobs    => _jobs;
  bool           get loading => _loading;
  String?        get error   => _error;
  bool           get hasMore => _hasMore;

  // Search / filter state
  String? filterLocation;
  String? filterTechStack;
  String? filterCompany;
  int?    filterExperience;

  Future<void> loadJobs({bool reset = false}) async {
    if (reset) {
      _page    = 0;
      _jobs    = [];
      _hasMore = true;
    }
    if (!_hasMore || _loading) return;
    _setLoading(true);
    try {
      final result = await _service.searchJobs(
        location:    filterLocation,
        techStack:   filterTechStack,
        companyName: filterCompany,
        experience:  filterExperience,
        postedBy:    ownerEmail,   // null for job-seekers, admin email for recruiters
        page:        _page,
      );
      if (result.isEmpty) {
        _hasMore = false;
      } else {
        _jobs.addAll(result);
        _page++;
      }
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> applyFilters({
    String? location,
    String? techStack,
    String? company,
    int?    experience,
  }) async {
    filterLocation   = location?.isEmpty  == true ? null : location;
    filterTechStack  = techStack?.isEmpty == true ? null : techStack;
    filterCompany    = company?.isEmpty   == true ? null : company;
    filterExperience = experience;
    await loadJobs(reset: true);
  }

  Future<JobModel> getJob(int id) => _service.getJob(id);

  Future<bool> createJob(JobModel job) async {
    _setLoading(true);
    try {
      await _service.createJob(job);
      await loadJobs(reset: true);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteJob(int id) async {
    try {
      await _service.deleteJob(id);
      _jobs.removeWhere((j) => j.id == id);
      notifyListeners();
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
