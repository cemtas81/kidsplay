class Parent {
  final String id;
  final String name;
  final String email;
  final String relationship;
  final String profileImageUrl;
  final bool isPrimary;
  final List<String> permissions;
  final DateTime joinedAt;

  Parent({
    required this.id,
    required this.name,
    required this.email,
    required this.relationship,
    required this.profileImageUrl,
    required this.isPrimary,
    required this.permissions,
    required this.joinedAt,
  });

  factory Parent.fromMap(String id, Map<String, dynamic> d) {
    return Parent(
      id: id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      relationship: d['relationship'] ?? '',
      profileImageUrl: d['profileImageUrl'] ?? '',
      isPrimary: d['isPrimary'] ?? false,
      permissions: List<String>.from(d['permissions'] ?? const []),
      joinedAt: DateTime.tryParse(d['joinedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'relationship': relationship,
        'profileImageUrl': profileImageUrl,
        'isPrimary': isPrimary,
        'permissions': permissions,
        'joinedAt': joinedAt.toIso8601String(),
      };
}