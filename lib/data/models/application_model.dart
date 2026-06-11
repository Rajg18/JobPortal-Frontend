class ApplicationModel {
  final int    id;
  final int?   jobId;       // null-safe: older responses may not include it
  final String jobTitle;
  final String companyName;
  final String status;
  final String appliedAt;

  const ApplicationModel({
    required this.id,
    this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.appliedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      ApplicationModel(
        id:          json['id']          as int,
        jobId:       json['jobId']       as int?,
        jobTitle:    json['jobTitle']    as String? ?? '',
        companyName: json['companyName'] as String? ?? '',
        status:      json['status']      as String? ?? 'PENDING',
        appliedAt:   json['appliedAt']   as String? ?? '',
      );
}
