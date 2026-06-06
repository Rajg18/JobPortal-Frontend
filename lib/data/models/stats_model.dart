class StatsModel {
  final int totalUsers;
  final int myJobs;
  final int myApplications;
  final int acceptedApplications;
  final int rejectedApplications;
  final int pendingApplications;

  const StatsModel({
    required this.totalUsers,
    required this.myJobs,
    required this.myApplications,
    required this.acceptedApplications,
    required this.rejectedApplications,
    required this.pendingApplications,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
    totalUsers:             json['totalUsers']            as int? ?? 0,
    myJobs:                 json['myJobs']                as int? ?? 0,
    myApplications:         json['myApplications']        as int? ?? 0,
    acceptedApplications:   json['acceptedApplications']  as int? ?? 0,
    rejectedApplications:   json['rejectedApplications']  as int? ?? 0,
    pendingApplications:    json['pendingApplications']   as int? ?? 0,
  );
}
