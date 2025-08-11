import 'package:flutter/material.dart';
import '../../data/content_repository.dart';

class HobbySelector extends StatefulWidget {
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  const HobbySelector({
    super.key,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  State<HobbySelector> createState() => _HobbySelectorState();
}

class _HobbySelectorState extends State<HobbySelector> {
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
        final hobbies = ContentRepository.instance.hobbies;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final h in hobbies)
              FilterChip(
                label: Text(h.nameKey), // Replace with localization if available
                selected: widget.selectedIds.contains(h.id),
                onSelected: (sel) {
                  final next = Set<String>.from(widget.selectedIds);
                  sel ? next.add(h.id) : next.remove(h.id);
                  widget.onChanged(next);
                },
              ),
          ],
        );
      },
    );
    }
}