class ProfileModel {
  final String email;
  final String skills;
  final String location;
  final String phone;
  final int    experience;

  const ProfileModel({
    required this.email,
    required this.skills,
    required this.location,
    required this.phone,
    required this.experience,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    email:      json['email'] as String? ?? '',
    skills:     json['skills'] as String? ?? '',
    location:   json['location'] as String? ?? '',
    phone:      json['phone'] as String? ?? '',
    experience: json['experience'] as int? ?? 0,
  );
}
