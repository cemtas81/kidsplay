import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_provider.dart';
import '../../services/user_data_service.dart';
import './widgets/hobby_selection_grid.dart';
import './widgets/play_duration_picker.dart';
import './widgets/profile_photo_section.dart';
import './widgets/screen_assessment_widget.dart';
import './widgets/step_progress_indicator.dart';

class ChildProfileCreation extends StatefulWidget {
  const ChildProfileCreation({super.key});

  @override
  State<ChildProfileCreation> createState() => _ChildProfileCreationState();
}

class _ChildProfileCreationState extends State<ChildProfileCreation>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final AuthProvider _authProvider = AuthProvider();
  final UserDataService _userDataService = UserDataService();

  int _currentStep = 1;
  final int _totalSteps = 4;

  // Form data
  final TextEditingController _nameController = TextEditingController();
  double _selectedAge = 3.0;
  String _selectedGender = '';
  XFile? _profilePhoto;
  List<String> _selectedHobbies = [];
  Map<String, dynamic> _assessmentData = {};
  int _playDuration = 60;
  List<String> _activityPreferences = [];

  final List<String> _stepLabels = [
    'Basic Info',
    'Interests',
    'Assessment',
    'Preferences',
  ];

  final List<Map<String, dynamic>> _genderOptions = [
    {'value': 'boy', 'label': 'Boy', 'icon': 'boy', 'color': Color(0xFF2196F3)},
    {
      'value': 'girl',
      'label': 'Girl',
      'icon': 'girl',
      'color': Color(0xFFE91E63)
    },
    {
      'value': 'other',
      'label': 'Other',
      'icon': 'child_care',
      'color': Color(0xFF9C27B0)
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 1:
        return _nameController.text.trim().isNotEmpty &&
            _selectedGender.isNotEmpty;
      case 2:
        return _selectedHobbies.isNotEmpty;
      case 3:
        return _assessmentData.isNotEmpty;
      case 4:
        return _activityPreferences.isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep()) {
      if (_currentStep < _totalSteps) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        HapticFeedback.lightImpact();
      } else {
        _completeProfile();
      }
    } else {
      _showValidationError();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _showValidationError() {
    String message = '';
    switch (_currentStep) {
      case 1:
        message = 'Please enter your child\'s name and select gender';
        break;
      case 2:
        message = 'Please select at least one interest';
        break;
      case 3:
        message = 'Please complete the screen time assessment';
        break;
      case 4:
        message = 'Please select at least one activity preference';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _completeProfile() async {
    if (_authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to create a child profile'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creating profile...'),
            ],
          ),
        ),
      );

      // Save child profile to Firebase
      final childId = await _userDataService.createChildProfile(
        parentId: _authProvider.currentUser!.uid,
        name: _nameController.text.trim(),
        age: _selectedAge.round(),
        gender: _selectedGender,
        hobbies: _selectedHobbies,
        additionalData: {
          'assessmentData': _assessmentData,
          'playDuration': _playDuration,
          'activityPreferences': _activityPreferences,
        },
      );

      // Update parent's hasChildren status
      await _authProvider.updateHasChildren(true);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'celebration',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 48,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Profile Created!',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Welcome to KidsPlay! Let\'s start exploring fun activities for ${_nameController.text}.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    Navigator.pop(context, 'profile_created'); // Return to dashboard with result
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Start Exploring'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s get to know your child',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tell us about your little one to personalize their experience',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),

          // Profile Photo Section
          Center(
            child: ProfilePhotoSection(
              selectedPhoto: _profilePhoto,
              onPhotoSelected: (photo) {
                setState(() {
                  _profilePhoto = photo;
                });
              },
            ),
          ),

          SizedBox(height: 4.h),

          // Name Input
          Text(
            'Child\'s Name',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your child\'s name',
              prefixIcon: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
            style: AppTheme.lightTheme.textTheme.bodyLarge,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) => setState(() {}),
          ),

          SizedBox(height: 3.h),

          // Age Selector
          Text(
            'Age: ${_selectedAge.toStringAsFixed(1)} years',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1.5 years',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
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
                        '${_selectedAge.toStringAsFixed(1)} years',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '6 years',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
                    inactiveTrackColor: AppTheme.lightTheme.colorScheme.primary
                        .withOpacity(0.3),
                    thumbColor: AppTheme.lightTheme.colorScheme.primary,
                    overlayColor: AppTheme.lightTheme.colorScheme.primary
                        .withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: _selectedAge,
                    min: 1.5,
                    max: 6.0,
                    divisions: 18,
                    onChanged: (value) {
                      setState(() {
                        _selectedAge = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Gender Selection
          Text(
            'Gender',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: _genderOptions.map((option) {
              final isSelected = _selectedGender == option['value'];

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGender = option['value'];
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                        right: option != _genderOptions.last ? 2.w : 0),
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? option['color'].withOpacity(0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? option['color']
                            : AppTheme.lightTheme.colorScheme.outline
                                .withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: option['icon'],
                          color: isSelected
                              ? option['color']
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          option['label'],
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: isSelected
                                ? option['color']
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What does ${_nameController.text.isNotEmpty ? _nameController.text : 'your child'} love?',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Select interests to get personalized activity recommendations',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          HobbySelectionGrid(
            selectedHobbies: _selectedHobbies,
            onHobbiesChanged: (hobbies) {
              setState(() {
                _selectedHobbies = hobbies;
              });
            },
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Screen Time Assessment',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Help us understand your child\'s current screen habits',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          ScreenAssessmentWidget(
            assessmentData: _assessmentData,
            onAssessmentChanged: (data) {
              setState(() {
                _assessmentData = data;
              });
            },
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Goals',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Set play duration goals and activity preferences',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          PlayDurationPicker(
            selectedDuration: _playDuration,
            onDurationChanged: (duration) {
              setState(() {
                _playDuration = duration;
              });
            },
            selectedPreferences: _activityPreferences,
            onPreferencesChanged: (preferences) {
              setState(() {
                _activityPreferences = preferences;
              });
            },
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                onPressed: _previousStep,
                icon: CustomIconWidget(
                  iconName: 'arrow_back_ios',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
        title: Text(
          'Create Child Profile',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: StepProgressIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                stepLabels: _stepLabels,
              ),
            ),

            SizedBox(height: 2.h),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),

            // Bottom Navigation
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_currentStep > 1)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 6.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 1) SizedBox(width: 4.w),
                    Expanded(
                      flex: _currentStep == 1 ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _canProceedToNextStep() ? _nextStep : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 6.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentStep == _totalSteps
                              ? 'Complete Profile'
                              : 'Next',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
