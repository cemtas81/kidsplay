import 'package:flutter/material.dart';
import '../../data/content_repository.dart';

class SkillSelector extends StatefulWidget {
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  const SkillSelector({
    super.key,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  State<SkillSelector> createState() => _SkillSelectorState();
}

class _SkillSelectorState extends State<SkillSelector> {
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
        final skills = ContentRepository.instance.skills;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in skills)
              FilterChip(
                label: Text(s.nameKey),
                selected: widget.selectedIds.contains(s.id),
                onSelected: (sel) {
                  final next = Set<String>.from(widget.selectedIds);
                  sel ? next.add(s.id) : next.remove(s.id);
                  widget.onChanged(next);
                },
              ),
          ],
        );
      },
    );
  }
}