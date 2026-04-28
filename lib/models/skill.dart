class Skill {
  final String title;
  final String description;
  final int yearsOfExperience;

  Skill({
    required this.title,
    required this.description,
    required this.yearsOfExperience,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      yearsOfExperience: (map['yearsOfExperience'] as num?)?.toInt() ?? 0,
    );
  }
}
