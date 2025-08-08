import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScreenAssessmentWidget extends StatefulWidget {
  final Map<String, dynamic> assessmentData;
  final Function(Map<String, dynamic>) onAssessmentChanged;

  const ScreenAssessmentWidget({
    super.key,
    required this.assessmentData,
    required this.onAssessmentChanged,
  });

  @override
  State<ScreenAssessmentWidget> createState() => _ScreenAssessmentWidgetState();
}

class _ScreenAssessmentWidgetState extends State<ScreenAssessmentWidget> {
  late Map<String, dynamic> _assessmentData;

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'daily_screen_time',
      'question': 'How many hours does your child spend on screens daily?',
      'type': 'slider',
      'min': 0.0,
      'max': 12.0,
      'divisions': 24,
      'unit': 'hours',
    },
    {
      'id': 'screen_dependency',
      'question': 'How dependent is your child on screens for entertainment?',
      'type': 'multiple_choice',
      'options': [
        {'value': 'low', 'label': 'Low - Can play without screens easily'},
        {'value': 'medium', 'label': 'Medium - Sometimes asks for screens'},
        {'value': 'high', 'label': 'High - Always wants screen time'},
        {'value': 'very_high', 'label': 'Very High - Tantrums without screens'},
      ],
    },
    {
      'id': 'screen_types',
      'question': 'What types of screens does your child use most?',
      'type': 'multiple_select',
      'options': [
        {'value': 'tablet', 'label': 'Tablet', 'icon': 'tablet'},
        {'value': 'phone', 'label': 'Smartphone', 'icon': 'smartphone'},
        {'value': 'tv', 'label': 'Television', 'icon': 'tv'},
        {'value': 'computer', 'label': 'Computer', 'icon': 'computer'},
        {
          'value': 'gaming',
          'label': 'Gaming Console',
          'icon': 'sports_esports'
        },
      ],
    },
    {
      'id': 'physical_activity',
      'question': 'How much physical activity does your child get daily?',
      'type': 'slider',
      'min': 0.0,
      'max': 8.0,
      'divisions': 16,
      'unit': 'hours',
    },
    {
      'id': 'sleep_quality',
      'question': 'How would you rate your child\'s sleep quality?',
      'type': 'multiple_choice',
      'options': [
        {'value': 'excellent', 'label': 'Excellent - Sleeps well every night'},
        {'value': 'good', 'label': 'Good - Usually sleeps well'},
        {'value': 'fair', 'label': 'Fair - Sometimes has trouble sleeping'},
        {'value': 'poor', 'label': 'Poor - Often has sleep issues'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _assessmentData = Map.from(widget.assessmentData);
  }

  void _updateAssessment(String key, dynamic value) {
    setState(() {
      _assessmentData[key] = value;
    });
    widget.onAssessmentChanged(_assessmentData);
  }

  Widget _buildSliderQuestion(Map<String, dynamic> question) {
    final value = (_assessmentData[question['id']] as double?) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0 ${question['unit']}',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} ${question['unit']}',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${question['max'].toInt()} ${question['unit']}',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
                  inactiveTrackColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  thumbColor: AppTheme.lightTheme.colorScheme.primary,
                  overlayColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: value,
                  min: question['min'],
                  max: question['max'],
                  divisions: question['divisions'],
                  onChanged: (newValue) {
                    _updateAssessment(question['id'], newValue);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceQuestion(Map<String, dynamic> question) {
    final selectedValue = _assessmentData[question['id']] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 2.h),
        Column(
          children: (question['options'] as List).map<Widget>((option) {
            final isSelected = selectedValue == option['value'];

            return GestureDetector(
              onTap: () => _updateAssessment(question['id'], option['value']),
              child: Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline,
                          width: 2,
                        ),
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            )
                          : null,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        option['label'],
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultipleSelectQuestion(Map<String, dynamic> question) {
    final selectedValues = (_assessmentData[question['id']] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question['question'],
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 2.5,
          ),
          itemCount: (question['options'] as List).length,
          itemBuilder: (context, index) {
            final option = (question['options'] as List)[index];
            final isSelected = selectedValues.contains(option['value']);

            return GestureDetector(
              onTap: () {
                final newValues = List.from(selectedValues);
                if (isSelected) {
                  newValues.remove(option['value']);
                } else {
                  newValues.add(option['value']);
                }
                _updateAssessment(question['id'], newValues);
              },
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: option['icon'],
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        option['label'],
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'slider':
        return _buildSliderQuestion(question);
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(question);
      case 'multiple_select':
        return _buildMultipleSelectQuestion(question);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'This assessment helps us recommend the best activities for your child\'s current screen habits.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          separatorBuilder: (context, index) => SizedBox(height: 4.h),
          itemBuilder: (context, index) {
            return _buildQuestion(_questions[index]);
          },
        ),
      ],
    );
  }
}
