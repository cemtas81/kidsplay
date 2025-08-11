import 'dart:convert';

class Tool {
  final String id;
  final String nameKey;
  final String category;

  Tool({required this.id, required this.nameKey, required this.category});

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String,
      category: json['category'] as String? ?? '',
    );
  }

  static List<Tool> listFromJsonString(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr) as List<dynamic>;
    return data.map((e) => Tool.fromJson(e as Map<String, dynamic>)).toList();
  }
}