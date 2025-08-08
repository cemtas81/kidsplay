import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlayDurationPicker extends StatefulWidget {
  final int selectedDuration;
  final Function(int) onDurationChanged;
  final List<String> selectedPreferences;
  final Function(List<String>) onPreferencesChanged;

  const PlayDurationPicker({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.selectedPreferences,
    required this.onPreferencesChanged,
  });

  @override
  State<PlayDurationPicker> createState() => _PlayDurationPickerState();
}

class _PlayDurationPickerState extends State<PlayDurationPicker> {
  late int _selectedDuration;
  late List<String> _selectedPreferences;

  final List<Map<String, dynamic>> _durationOptions = [
    {'minutes': 15, 'label': '15 min', 'description': 'Quick activities'},
    {'minutes': 30, 'label': '30 min', 'description': 'Short play sessions'},
    {'minutes': 45, 'label': '45 min', 'description': 'Medium activities'},
    {'minutes': 60, 'label': '1 hour', 'description': 'Extended play'},
    {'minutes': 90, 'label': '1.5 hours', 'description': 'Long activities'},
    {'minutes': 120, 'label': '2 hours', 'description': 'Full play sessions'},
  ];

  final List<Map<String, dynamic>> _activityPreferences = [
    {
      'id': 'indoor',
      'label': 'Indoor Activities',
      'icon': 'home',
      'color': Color(0xFF4CAF50),
      'description': 'Activities that can be done inside',
    },
    {
      'id': 'outdoor',
      'label': 'Outdoor Activities',
      'icon': 'park',
      'color': Color(0xFF2196F3),
      'description': 'Activities that require outdoor space',
    },
    {
      'id': 'quiet',
      'label': 'Quiet Activities',
      'icon': 'volume_off',
      'color': Color(0xFF9C27B0),
      'description': 'Low-noise activities for calm time',
    },
    {
      'id': 'active',
      'label': 'Active Play',
      'icon': 'directions_run',
      'color': Color(0xFFFF5722),
      'description': 'High-energy physical activities',
    },
    {
      'id': 'creative',
      'label': 'Creative Time',
      'icon': 'palette',
      'color': Color(0xFFE91E63),
      'description': 'Arts, crafts, and creative expression',
    },
    {
      'id': 'learning',
      'label': 'Learning Fun',
      'icon': 'school',
      'color': Color(0xFF3F51B5),
      'description': 'Educational and skill-building activities',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.selectedDuration;
    _selectedPreferences = List.from(widget.selectedPreferences);
  }

  void _updateDuration(int duration) {
    setState(() {
      _selectedDuration = duration;
    });
    widget.onDurationChanged(duration);
  }

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });
    widget.onPreferencesChanged(_selectedPreferences);
  }

  Widget _buildDurationOption(Map<String, dynamic> option) {
    final isSelected = _selectedDuration == option['minutes'];

    return GestureDetector(
      onTap: () => _updateDuration(option['minutes']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'schedule',
                color: isSelected
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              option['label'],
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              option['description'],
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              SizedBox(height: 1.h),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(Map<String, dynamic> preference) {
    final isSelected = _selectedPreferences.contains(preference['id']);

    return GestureDetector(
      onTap: () => _togglePreference(preference['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? preference['color'].withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? preference['color']
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? preference['color']
                    : preference['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: preference['icon'],
                color: isSelected ? Colors.white : preference['color'],
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preference['label'],
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? preference['color']
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    preference['description'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? preference['color']
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: preference['color'],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPreferencesChips() {
    if (_selectedPreferences.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        Text(
          'Selected Preferences (${_selectedPreferences.length})',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _selectedPreferences.map((prefId) {
            final preference = _activityPreferences.firstWhere(
              (p) => p['id'] == prefId,
            );

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: preference['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: preference['color'].withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: preference['icon'],
                    color: preference['color'],
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    preference['label'],
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: preference['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  GestureDetector(
                    onTap: () => _togglePreference(prefId),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: preference['color'],
                      size: 12,
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
        Text(
          'Daily Play Duration Goal',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'How much time would you like your child to spend on physical activities daily?',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.1,
          ),
          itemCount: _durationOptions.length,
          itemBuilder: (context, index) {
            return _buildDurationOption(_durationOptions[index]);
          },
        ),
        SizedBox(height: 4.h),
        Text(
          'Activity Preferences',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'What types of activities would you like to focus on? (Select multiple)',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 3.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activityPreferences.length,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            return _buildPreferenceCard(_activityPreferences[index]);
          },
        ),
        _buildSelectedPreferencesChips(),
      ],
    );
  }
}
