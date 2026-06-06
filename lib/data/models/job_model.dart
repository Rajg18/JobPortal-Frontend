class JobModel {
  final int    id;
  final String title;
  final String description;
  final String location;
  final String techStack;
  final int    experienceRequired;
  final String companyName;
  final String createdAt;
  final String postedBy;

  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.techStack,
    required this.experienceRequired,
    required this.companyName,
    required this.createdAt,
    required this.postedBy,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
    id:                  json['id'] as int,
    title:               json['title'] as String? ?? '',
    description:         json['description'] as String? ?? '',
    location:            json['location'] as String? ?? '',
    techStack:           json['techStack'] as String? ?? '',
    experienceRequired:  json['experienceRequired'] as int? ?? 0,
    companyName:         json['companyName'] as String? ?? '',
    createdAt:           json['createdAt'] as String? ?? '',
    postedBy:            json['postedBy'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'title':              title,
    'description':        description,
    'location':           location,
    'techStack':          techStack,
    'experienceRequired': experienceRequired,
    'companyName':        companyName,
  };
}
