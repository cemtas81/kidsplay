import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HobbySelectionGrid extends StatefulWidget {
  final List<String> selectedHobbies;
  final Function(List<String>) onHobbiesChanged;

  const HobbySelectionGrid({
    super.key,
    required this.selectedHobbies,
    required this.onHobbiesChanged,
  });

  @override
  State<HobbySelectionGrid> createState() => _HobbySelectionGridState();
}

class _HobbySelectionGridState extends State<HobbySelectionGrid> {
  final TextEditingController _customHobbyController = TextEditingController();
  late List<String> _selectedHobbies;

  final List<Map<String, dynamic>> _hobbies = [
    {'name': 'Sports', 'icon': 'sports_soccer', 'color': Color(0xFF4CAF50)},
    {'name': 'Arts & Crafts', 'icon': 'palette', 'color': Color(0xFFE91E63)},
    {'name': 'Music', 'icon': 'music_note', 'color': Color(0xFF9C27B0)},
    {'name': 'Building', 'icon': 'construction', 'color': Color(0xFFFF9800)},
    {'name': 'Reading', 'icon': 'menu_book', 'color': Color(0xFF3F51B5)},
    {'name': 'Dancing', 'icon': 'music_video', 'color': Color(0xFFE91E63)},
    {'name': 'Cooking', 'icon': 'restaurant', 'color': Color(0xFFFF5722)},
    {'name': 'Gardening', 'icon': 'local_florist', 'color': Color(0xFF4CAF50)},
    {'name': 'Science', 'icon': 'science', 'color': Color(0xFF00BCD4)},
    {'name': 'Puzzles', 'icon': 'extension', 'color': Color(0xFF795548)},
    {'name': 'Animals', 'icon': 'pets', 'color': Color(0xFF8BC34A)},
    {'name': 'Technology', 'icon': 'computer', 'color': Color(0xFF607D8B)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedHobbies = List.from(widget.selectedHobbies);
  }

  @override
  void dispose() {
    _customHobbyController.dispose();
    super.dispose();
  }

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else {
        _selectedHobbies.add(hobby);
      }
    });
    widget.onHobbiesChanged(_selectedHobbies);
  }

  void _addCustomHobby() {
    final customHobby = _customHobbyController.text.trim();
    if (customHobby.isNotEmpty && !_selectedHobbies.contains(customHobby)) {
      setState(() {
        _selectedHobbies.add(customHobby);
        _customHobbyController.clear();
      });
      widget.onHobbiesChanged(_selectedHobbies);
    }
  }

  void _showCustomHobbyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add Custom Interest',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: TextField(
          controller: _customHobbyController,
          decoration: InputDecoration(
            hintText: 'Enter your child\'s interest',
            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customHobbyController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addCustomHobby();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildHobbyCard(Map<String, dynamic> hobby) {
    final isSelected = _selectedHobbies.contains(hobby['name']);

    return GestureDetector(
      onTap: () => _toggleHobby(hobby['name']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? hobby['color'].withValues(alpha: 0.15)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? hobby['color']
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: hobby['color'].withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? hobby['color']
                    : hobby['color'].withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: hobby['icon'],
                color: isSelected ? Colors.white : hobby['color'],
                size: 28,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              hobby['name'],
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? hobby['color']
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              SizedBox(height: 0.5.h),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: hobby['color'],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHobbyCard() {
    return GestureDetector(
      onTap: _showCustomHobbyDialog,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 28,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Add Custom',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedHobbiesChips() {
    if (_selectedHobbies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        Text(
          'Selected Interests (${_selectedHobbies.length})',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _selectedHobbies.map((hobby) {
            final hobbyData = _hobbies.firstWhere(
              (h) => h['name'] == hobby,
              orElse: () => {
                'name': hobby,
                'icon': 'star',
                'color': AppTheme.lightTheme.colorScheme.primary
              },
            );

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: hobbyData['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hobbyData['color'].withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: hobbyData['icon'],
                    color: hobbyData['color'],
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    hobby,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: hobbyData['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  GestureDetector(
                    onTap: () => _toggleHobby(hobby),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: hobbyData['color'],
                      size: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 0.85,
          ),
          itemCount: _hobbies.length + 1,
          itemBuilder: (context, index) {
            if (index == _hobbies.length) {
              return _buildCustomHobbyCard();
            }
            return _buildHobbyCard(_hobbies[index]);
          },
        ),
        _buildSelectedHobbiesChips(),
      ],
    );
  }
}
