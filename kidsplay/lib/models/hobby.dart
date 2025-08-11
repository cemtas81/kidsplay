import 'dart:convert';

class Hobby {
  final String id;
  final String nameKey;
  final String category;

  Hobby({required this.id, required this.nameKey, required this.category});

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String,
      category: json['category'] as String? ?? '',
    );
  }

  static List<Hobby> listFromJsonString(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    return data.map((e) => Hobby.fromJson(e as Map<String, dynamic>)).toList();
  }
}