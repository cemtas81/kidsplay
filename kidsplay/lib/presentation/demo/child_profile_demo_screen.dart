import 'package:flutter/material.dart';
import '../../models/child_profile.dart';
import '../../widgets/selectors/hobby_selector.dart';
import '../../widgets/selectors/skill_selector.dart';
import '../../widgets/selectors/tool_selector.dart';
import '../../widgets/recommendations/activity_recommendations.dart';

class ChildProfileDemoScreen extends StatefulWidget {
  const ChildProfileDemoScreen({super.key});

  @override
  State<ChildProfileDemoScreen> createState() => _ChildProfileDemoScreenState();
}

class _ChildProfileDemoScreenState extends State<ChildProfileDemoScreen> {
  ChildProfile child = ChildProfile(
    id: 'demo',
    name: 'Demo Kid',
    ageMonths: 48, // 4 years
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Profile (Demo)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hobbies', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            HobbySelector(
              selectedIds: child.hobbyIds,
              onChanged: (set) => setState(() {
                child = child.copyWith(hobbyIds: set);
              }),
            ),
            const SizedBox(height: 16),

            Text('Skills', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SkillSelector(
              selectedIds: child.skillIds,
              onChanged: (set) => setState(() {
                child = child.copyWith(skillIds: set);
              }),
            ),
            const SizedBox(height: 16),

            Text('Tools', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ToolSelector(
              selectedIds: child.toolIds,
              onChanged: (set) => setState(() {
                child = child.copyWith(toolIds: set);
              }),
            ),
            const SizedBox(height: 24),

            Text('Recommended Activities', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ActivityRecommendations(child: child),
          ],
        ),
      ),
    );
  }
}