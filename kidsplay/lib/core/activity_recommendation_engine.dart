import 'dart:math';
import '../models/activity.dart';
import '../models/child.dart';
import '../models/tool.dart';

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
    int childAgeMonths = _calculateAgeInMonths(child.birthDate);
    
    // If no age constraints, consider compatible
    if (activity.minAgeMonths == null && activity.maxAgeMonths == null) {
      return true;
    }
    
    bool minAgeOk = activity.minAgeMonths == null || childAgeMonths >= activity.minAgeMonths!;
    bool maxAgeOk = activity.maxAgeMonths == null || childAgeMonths <= activity.maxAgeMonths!;
    
    return minAgeOk && maxAgeOk;
  }

  static double _calculateHobbyMatch(Activity activity, Child child) {
    if (child.hobbies.isEmpty) return 0.5; // Neutral score if no hobbies

    int matchingHobbies = 0;
    for (String hobby in child.hobbies) {
      if (activity.hobbies.contains(hobby)) {
        matchingHobbies++;
      }
    }

    return matchingHobbies / child.hobbies.length;
  }

  static double _calculateToolAvailability(Activity activity, List<Tool> availableTools) {
    if (activity.tools.isEmpty) return 1.0;

    int availableRequiredTools = 0;
    for (String requiredTool in activity.tools) {
      if (availableTools.any((tool) => tool.nameKey.toLowerCase().contains(requiredTool.toLowerCase()) ||
                                       tool.id == requiredTool)) {
        availableRequiredTools++;
      }
    }

    return availableRequiredTools / activity.tools.length;
  }

  static bool _isParentCompatible(Activity activity, bool parentAvailable) {
    // Since the new Activity model doesn't have requiresParent field,
    // we'll assume all activities are compatible for now
    // This could be enhanced by adding metadata to the Activity model
    return true;
  }

  static bool _isEnergyLevelCompatible(Activity activity, Child child) {
    // Since the new Activity model doesn't have energyLevel field,
    // we'll assume all activities are compatible for now
    // This could be enhanced by adding energy level categorization
    return true;
  }

  static int _calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static int _calculateAgeInMonths(DateTime birthDate) {
    DateTime now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  static List<Activity> getRandomActivities({
    required List<Activity> allActivities,
    required Child child,
    int count = 3,
  }) {
    List<Activity> suitableActivities = allActivities.where((activity) {
      return _isAgeCompatible(activity, child);
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
