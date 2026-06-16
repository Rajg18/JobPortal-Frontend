class ProfileModel {
  final String email;
  final String skills;
  final String location;
  final String phone;
  final int    experience;
  // AI resume fields
  final String? parsedSkills;
  final String? parsedTechStack;
  final bool    resumeUploaded;

  const ProfileModel({
    required this.email,
    required this.skills,
    required this.location,
    required this.phone,
    required this.experience,
    this.parsedSkills,
    this.parsedTechStack,
    this.resumeUploaded = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    email:          json['email']          as String? ?? '',
    skills:         json['skills']         as String? ?? '',
    location:       json['location']       as String? ?? '',
    phone:          json['phone']          as String? ?? '',
    experience:     json['experience']     as int?    ?? 0,
    parsedSkills:   json['parsedSkills']   as String?,
    parsedTechStack: json['parsedTechStack'] as String?,
    resumeUploaded: json['resumeUploaded'] as bool?   ?? false,
  );

  // Parse the JSON array strings returned by the AI into a clean Dart list.
  // e.g. '["Java","Spring Boot","MySQL"]' → ['Java', 'Spring Boot', 'MySQL']
  List<String> get parsedSkillsList   => _parseJsonArray(parsedSkills);
  List<String> get parsedTechStackList => _parseJsonArray(parsedTechStack);

  static List<String> _parseJsonArray(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      // Strip brackets, split by comma, remove surrounding quotes
      final inner = raw.trim().replaceAll('[', '').replaceAll(']', '');
      return inner
          .split(',')
          .map((s) => s.trim().replaceAll('"', ''))
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
