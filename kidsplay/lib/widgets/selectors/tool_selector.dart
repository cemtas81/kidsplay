import 'package:flutter/material.dart';
import '../../data/content_repository.dart';

class ToolSelector extends StatefulWidget {
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  const ToolSelector({
    super.key,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  State<ToolSelector> createState() => _ToolSelectorState();
}

class _ToolSelectorState extends State<ToolSelector> {
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
        final tools = ContentRepository.instance.tools;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in tools)
              FilterChip(
                label: Text(t.nameKey),
                selected: widget.selectedIds.contains(t.id),
                onSelected: (sel) {
                  final next = Set<String>.from(widget.selectedIds);
                  sel ? next.add(t.id) : next.remove(t.id);
                  widget.onChanged(next);
                },
              ),
          ],
        );
      },
    );
  }
}