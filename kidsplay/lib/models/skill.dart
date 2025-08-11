import 'dart:convert';

class Skill {
  final String id;
  final String nameKey;
  final String category;

  Skill({required this.id, required this.nameKey, required this.category});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String,
      category: json['category'] as String? ?? '',
    );
  }

  static List<Skill> listFromJsonString(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    return data.map((e) => Skill.fromJson(e as Map<String, dynamic>)).toList();
  }
}