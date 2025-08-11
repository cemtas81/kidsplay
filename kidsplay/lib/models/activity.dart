import 'dart:convert';

class Activity {
  final String id;
  final String nameKey;
  final String? descriptionKey;

  // Age gating in months
  final int? minAgeMonths;
  final int? maxAgeMonths;

  // Associations (IDs)
  final List<String> hobbies;
  final List<String> skills;
  final List<String> tools;
  final List<String> categories;

  Activity({
    required this.id,
    required this.nameKey,
    this.descriptionKey,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.hobbies = const [],
    this.skills = const [],
    this.tools = const [],
    this.categories = const [],
  });

  static List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is List) {
        return v.whereType<String>().toList();
      }
    }
    return const [];
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    final hobbies = _readStringList(json, ['hobbies', 'requiredHobbies', 'relatedHobbies']);
    final skills  = _readStringList(json, ['skills', 'requiredSkills', 'relatedSkills']);
    final tools   = _readStringList(json, ['tools', 'requiredTools', 'relatedTools']);
    final cats    = _readStringList(json, ['categories', 'category']);

    int? _toInt(dynamic v) => (v is num) ? v.toInt() : null;

    return Activity(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String? ?? json['titleKey'] as String? ?? json['title'] as String? ?? '',
      descriptionKey: json['descriptionKey'] as String? ?? json['descKey'] as String?,
      minAgeMonths: _toInt(json['minAgeMonths'] ?? json['minAge'] ?? json['min_age_months']),
      maxAgeMonths: _toInt(json['maxAgeMonths'] ?? json['maxAge'] ?? json['max_age_months']),
      hobbies: hobbies,
      skills: skills,
      tools: tools,
      categories: cats,
    );
  }

  static List<Activity> listFromJsonString(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    return data.map((e) => Activity.fromJson(e as Map<String, dynamic>)).toList();
  }
}