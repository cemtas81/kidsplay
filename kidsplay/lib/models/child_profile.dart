class ChildProfile {
  final String id;
  final String name;
  final int ageMonths; // store in months

  final Set<String> hobbyIds;
  final Set<String> skillIds;
  final Set<String> toolIds;

  ChildProfile({
    required this.id,
    required this.name,
    required this.ageMonths,
    Set<String>? hobbyIds,
    Set<String>? skillIds,
    Set<String>? toolIds,
  })  : hobbyIds = hobbyIds ?? <String>{},
        skillIds = skillIds ?? <String>{},
        toolIds = toolIds ?? <String>{};

  ChildProfile copyWith({
    String? id,
    String? name,
    int? ageMonths,
    Set<String>? hobbyIds,
    Set<String>? skillIds,
    Set<String>? toolIds,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      ageMonths: ageMonths ?? this.ageMonths,
      hobbyIds: hobbyIds ?? this.hobbyIds,
      skillIds: skillIds ?? this.skillIds,
      toolIds: toolIds ?? this.toolIds,
    );
  }
}