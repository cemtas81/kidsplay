import 'package:flutter/material.dart';
import '../../data/content_repository.dart';
import '../../models/child_profile.dart';
import '../../services/recommendation_service.dart';

class ActivityRecommendations extends StatefulWidget {
  final ChildProfile child;
  final int limit;

  const ActivityRecommendations({
    super.key,
    required this.child,
    this.limit = 20,
  });

  @override
  State<ActivityRecommendations> createState() => _ActivityRecommendationsState();
}

class _ActivityRecommendationsState extends State<ActivityRecommendations> {
  final _service = const RecommendationService();
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = ContentRepository.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final repo = ContentRepository.instance;
        final items = _service.recommend(
          child: widget.child,
          allActivities: repo.activities,
          limit: widget.limit,
          minScore: 1.0,
        );

        if (items.isEmpty) {
          return const Text('No matching activities yet');
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final a = items[index];
            return ListTile(
              title: Text(a.nameKey),
              subtitle: a.descriptionKey != null ? Text(a.descriptionKey!) : null,
              trailing: _AgeBadge(minAge: a.minAgeMonths, maxAge: a.maxAgeMonths),
            );
          },
        );
      },
    );
  }
}

class _AgeBadge extends StatelessWidget {
  final int? minAge;
  final int? maxAge;
  const _AgeBadge({this.minAge, this.maxAge});

  @override
  Widget build(BuildContext context) {
    if (minAge == null && maxAge == null) return const SizedBox.shrink();
    final parts = <String>[];
    if (minAge != null) parts.add('≥${(minAge! / 12).toStringAsFixed(minAge! % 12 == 0 ? 0 : 1)}y');
    if (maxAge != null) parts.add('≤${(maxAge! / 12).toStringAsFixed(maxAge! % 12 == 0 ? 0 : 1)}y');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        parts.join(' '),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}