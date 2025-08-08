import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step $currentStep of $totalSteps',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${((currentStep / totalSteps) * 100).round()}% Complete',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;
              final isUpcoming = stepNumber > currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStepIndicator(
                        stepNumber: stepNumber,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isUpcoming: isUpcoming,
                        label: stepLabels[index],
                      ),
                    ),
                    if (index < totalSteps - 1)
                      _buildConnector(
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUpcoming,
    required String label,
  }) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    Widget icon;

    if (isCompleted) {
      backgroundColor = AppTheme.lightTheme.colorScheme.primary;
      iconColor = Colors.white;
      textColor = AppTheme.lightTheme.colorScheme.primary;
      icon = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isCurrent) {
      backgroundColor = AppTheme.lightTheme.colorScheme.primary;
      iconColor = Colors.white;
      textColor = AppTheme.lightTheme.colorScheme.primary;
      icon = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: iconColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      backgroundColor =
          AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2);
      iconColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      textColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      icon = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: iconColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Center(child: icon),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildConnector({
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return Container(
      width: 4.w,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: isCompleted || isCurrent
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
