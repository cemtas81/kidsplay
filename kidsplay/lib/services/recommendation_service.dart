import '../models/activity.dart';
import '../models/child_profile.dart';

class RecommendationService {
  const RecommendationService();

  static const double _ageWeight = 1.0;
  static const double _hobbyWeight = 3.0;
  static const double _skillWeight = 2.0;
  static const double _toolWeight = 1.0;

  List<Activity> recommend({
    required ChildProfile child,
    required List<Activity> allActivities,
    int limit = 20,
    double minScore = 1.0,
  }) {
    final scored = <_ScoredActivity>[];

    for (final a in allActivities) {
      double score = 0;

      // Age gating
      final withinMin = a.minAgeMonths == null || child.ageMonths >= a.minAgeMonths!;
      final withinMax = a.maxAgeMonths == null || child.ageMonths <= a.maxAgeMonths!;
      final ageOk = withinMin && withinMax;
      if (ageOk) score += _ageWeight;

      // Overlaps
      final hobbyMatches = a.hobbies.where((id) => child.hobbyIds.contains(id)).length;
      final skillMatches = a.skills.where((id) => child.skillIds.contains(id)).length;
      final toolMatches = a.tools.where((id) => child.toolIds.contains(id)).length;

      score += hobbyMatches * _hobbyWeight;
      score += skillMatches * _skillWeight;
      score += toolMatches * _toolWeight;

      if (score >= minScore) {
        scored.add(_ScoredActivity(activity: a, score: score));
      }
    }

    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      final aSpan = _ageSpan(a.activity);
      final bSpan = _ageSpan(b.activity);
      final spanCmp = aSpan.compareTo(bSpan);
      if (spanCmp != 0) return spanCmp;
      return a.activity.id.compareTo(b.activity.id);
    });

    return scored.take(limit).map((e) => e.activity).toList();
  }

  int _ageSpan(Activity a) {
    final min = a.minAgeMonths ?? 0;
    final max = a.maxAgeMonths ?? 1000;
    return (max - min).abs();
  }
}

class _ScoredActivity {
  final Activity activity;
  final double score;
  _ScoredActivity({required this.activity, required this.score});
}