import 'dart:math';

class ActivityRecommendationEngine {
  static List<Activity> getRecommendedActivities({
    required Child child,
    required List<Tool> availableTools,
    required List<Activity> allActivities,
    required bool parentAvailable,
    int limit = 5,
  }) {
    List<ActivityScore> scoredActivities = [];

    for (Activity activity in allActivities) {
      double score = _calculateActivityScore(
        activity: activity,
        child: child,
        availableTools: availableTools,
        parentAvailable: parentAvailable,
      );

      if (score > 0) {
        scoredActivities.add(ActivityScore(activity: activity, score: score));
      }
    }

    // Sort by score (highest first) and return top activities
    scoredActivities.sort((a, b) => b.score.compareTo(a.score));
    
    return scoredActivities
        .take(limit)
        .map((scored) => scored.activity)
        .toList();
  }

  static double _calculateActivityScore({
    required Activity activity,
    required Child child,
    required List<Tool> availableTools,
    required bool parentAvailable,
  }) {
    double score = 0.0;

    // Age compatibility (40% weight)
    if (_isAgeCompatible(activity, child)) {
      score += 40.0;
    }

    // Hobby match (25% weight)
    double hobbyScore = _calculateHobbyMatch(activity, child);
    score += hobbyScore * 25.0;

    // Tool availability (20% weight)
    double toolScore = _calculateToolAvailability(activity, availableTools);
    score += toolScore * 20.0;

    // Parent availability (10% weight)
    if (_isParentCompatible(activity, parentAvailable)) {
      score += 10.0;
    }

    // Energy level match (5% weight)
    if (_isEnergyLevelCompatible(activity, child)) {
      score += 5.0;
    }

    return score;
  }

  static bool _isAgeCompatible(Activity activity, Child child) {
    int childAge = _calculateAge(child.birthDate);
    return activity.minAge <= childAge && childAge <= activity.maxAge;
  }

  static double _calculateHobbyMatch(Activity activity, Child child) {
    if (child.hobbies.isEmpty) return 0.5; // Neutral score if no hobbies

    int matchingHobbies = 0;
    for (String hobby in child.hobbies) {
      if (activity.relatedHobbies.contains(hobby)) {
        matchingHobbies++;
      }
    }

    return matchingHobbies / child.hobbies.length;
  }

  static double _calculateToolAvailability(Activity activity, List<Tool> availableTools) {
    if (activity.requiredTools.isEmpty) return 1.0;

    int availableRequiredTools = 0;
    for (String requiredTool in activity.requiredTools) {
      if (availableTools.any((tool) => tool.name.toLowerCase().contains(requiredTool.toLowerCase()))) {
        availableRequiredTools++;
      }
    }

    return availableRequiredTools / activity.requiredTools.length;
  }

  static bool _isParentCompatible(Activity activity, bool parentAvailable) {
    if (activity.requiresParent && !parentAvailable) return false;
    return true;
  }

  static bool _isEnergyLevelCompatible(Activity activity, Child child) {
    // Simple energy level matching based on screen dependency
    if (child.screenDependencyLevel == 'high' && activity.energyLevel == 'high') {
      return true;
    } else if (child.screenDependencyLevel == 'low' && activity.energyLevel == 'low') {
      return true;
    }
    return activity.energyLevel == 'medium';
  }

  static int _calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static List<Activity> getRandomActivities({
    required List<Activity> allActivities,
    required Child child,
    int count = 3,
  }) {
    List<Activity> suitableActivities = allActivities.where((activity) {
      int childAge = _calculateAge(child.birthDate);
      return activity.minAge <= childAge && childAge <= activity.maxAge;
    }).toList();

    if (suitableActivities.length <= count) {
      return suitableActivities;
    }

    List<Activity> randomActivities = [];
    Random random = Random();
    
    while (randomActivities.length < count) {
      int index = random.nextInt(suitableActivities.length);
      Activity activity = suitableActivities[index];
      
      if (!randomActivities.contains(activity)) {
        randomActivities.add(activity);
      }
    }

    return randomActivities;
  }
}

class ActivityScore {
  final Activity activity;
  final double score;

  ActivityScore({required this.activity, required this.score});
}

class Activity {
  final String id;
  final String name;
  final String description;
  final List<String> relatedHobbies;
  final List<String> requiredTools;
  final int duration; // in minutes
  final int minAge;
  final int maxAge;
  final String activityType; // creative, physical, musical, educational, free_play
  final bool requiresParent;
  final bool needsCamera;
  final bool needsCameraEvaluation;
  final String energyLevel; // low, medium, high
  final bool hasAudioInstructions;
  final bool hasVisualInstructions;
  final bool hasPoints;
  final bool allowsResultUpload;
  final String expectedOutput; // none, image, video, audio
  final bool needsParentFeedback;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.relatedHobbies,
    required this.requiredTools,
    required this.duration,
    required this.minAge,
    required this.maxAge,
    required this.activityType,
    required this.requiresParent,
    required this.needsCamera,
    required this.needsCameraEvaluation,
    required this.energyLevel,
    required this.hasAudioInstructions,
    required this.hasVisualInstructions,
    required this.hasPoints,
    required this.allowsResultUpload,
    required this.expectedOutput,
    required this.needsParentFeedback,
  });
}

class Child {
  final String id;
  final String name;
  final String surname;
  final DateTime birthDate;
  final String gender;
  final List<String> hobbies;
  final bool hasScreenDependency;
  final String screenDependencyLevel; // low, normal, high
  final bool usesScreenDuringMeals;
  final bool wantsToChange;
  final String dailyPlayTime; // 15min, 30min, 1h, 2h, 3h+
  final List<String> parentIds;
  final String relationshipToParent; // mother, father, guardian, legal_representative
  final bool hasCameraPermission;

  Child({
    required this.id,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.gender,
    required this.hobbies,
    required this.hasScreenDependency,
    required this.screenDependencyLevel,
    required this.usesScreenDuringMeals,
    required this.wantsToChange,
    required this.dailyPlayTime,
    required this.parentIds,
    required this.relationshipToParent,
    required this.hasCameraPermission,
  });
}

class Tool {
  final String id;
  final String name;
  final String imageUrl;
  final String category; // kitchen, toys, art, etc.

  Tool({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
  });
}
