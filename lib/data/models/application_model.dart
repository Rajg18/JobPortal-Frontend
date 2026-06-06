class ApplicationModel {
  final int    id;
  final String jobTitle;
  final String companyName;
  final String status;
  final String appliedAt;

  const ApplicationModel({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.appliedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) => ApplicationModel(
    id:          json['id'] as int,
    jobTitle:    json['jobTitle'] as String? ?? '',
    companyName: json['companyName'] as String? ?? '',
    status:      json['status'] as String? ?? 'PENDING',
    appliedAt:   json['appliedAt'] as String? ?? '',
  );
}
