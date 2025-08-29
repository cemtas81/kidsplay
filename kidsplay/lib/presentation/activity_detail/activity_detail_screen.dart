import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/activity.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final Child child;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    required this.child,
  }) : super(key: key);

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isActivityStarted = false;
  bool _isActivityCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _currentStep = 0;
  List<String> _activitySteps = [];
  String? _resultImagePath;

  @override
  void initState() {
    super.initState();
    _initializeActivity();
    _initializeCamera();
    _setupAnimations();
  }

  void _initializeActivity() {
    // Parse activity steps from description or create default steps
    _activitySteps = _parseActivitySteps(widget.activity.descriptionKey ?? 'No description available');
  }

  List<String> _parseActivitySteps(String description) {
    // Simple step parsing - in real app, this would be more sophisticated
    List<String> steps = [];
    steps.add('Hazırlık yapın');
    steps.add('Aktiviteyi başlatın');
    steps.add('Talimatları takip edin');
    steps.add('Aktiviteyi tamamlayın');
    return steps;
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeCamera() async {
    if (!widget.activity.needsCamera) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: CustomAppBar(
        title: 'Activity Details',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              // Share activity
            },
            icon: CustomIconWidget(
              iconName: 'share',
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(context),
            SizedBox(height: 3.h),
            _buildActivityInfo(context),
            SizedBox(height: 3.h),
            _buildActivitySteps(context),
            if (widget.activity.needsCamera) ...[
              SizedBox(height: 3.h),
              _buildCameraSection(context),
            ],
            SizedBox(height: 4.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getActivityIcon(widget.activity.categories.isNotEmpty ? widget.activity.categories.first : 'general'),
                      color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.activity.nameKey,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Activity', // Placeholder since duration is not available
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              widget.activity.descriptionKey ?? 'No description available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            if (widget.activity.categories.isNotEmpty)
              _buildInfoRow(context, 'Categories', widget.activity.categories.join(', ')),
            if (widget.activity.hobbies.isNotEmpty)
              _buildInfoRow(context, 'Related Hobbies', widget.activity.hobbies.join(', ')),
            if (widget.activity.tools.isNotEmpty)
              _buildInfoRow(context, 'Required Tools', widget.activity.tools.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySteps(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Activity Steps',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentStep + 1}/${_activitySteps.length}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            LinearProgressIndicator(
              value: (_currentStep + 1) / _activitySteps.length,
              backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              ),
              minHeight: 6,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _activitySteps[_currentStep],
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Camera Preview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            if (_isCameraInitialized)
              Container(
                height: 30.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              Container(
                height: 30.h,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'camera_alt',
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Camera not available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
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

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          if (!_isActivityStarted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  foregroundColor: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_isActivityStarted && !_isActivityCompleted) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentStep > 0 ? _previousStep : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      side: BorderSide(
                        color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      foregroundColor: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == _activitySteps.length - 1 ? 'Complete' : 'Next Step',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_isActivityCompleted) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showParentFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
                  foregroundColor: isDark ? AppTheme.onSecondaryDark : AppTheme.onSecondaryLight,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Parent Feedback',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppTheme.onSecondaryDark : AppTheme.onSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startActivity() {
    setState(() {
      _isActivityStarted = true;
      _currentStep = 0;
    });
    _animationController.forward();
  }

  void _nextStep() {
    if (_currentStep < _activitySteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _completeActivity() {
    setState(() {
      _isActivityCompleted = true;
      _currentStep = _activitySteps.length;
    });
    
    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tebrikler!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Aktiviteyi başarıyla tamamladınız!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(color: const Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showParentFeedback() {
    // Navigate to parent feedback screen
    Navigator.pushNamed(context, '/parent-feedback', arguments: {
      'activity': widget.activity,
      'child': widget.child,
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _resultImagePath = photo.path;
      });
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _recordVideo() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      if (_isRecording) {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
      } else {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print('Error recording video: $e');
    }
  }

  IconData _getActivityTypeIcon(String activityType) {
    switch (activityType) {
      case 'creative':
        return Icons.brush;
      case 'physical':
        return Icons.directions_run;
      case 'musical':
        return Icons.music_note;
      case 'educational':
        return Icons.school;
      case 'free_play':
        return Icons.toys;
      default:
        return Icons.star;
    }
  }

  String _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'creative':
        return 'brush';
      case 'physical':
        return 'directions_run';
      case 'musical':
        return 'music_note';
      case 'educational':
        return 'school';
      case 'free_play':
        return 'toys';
      default:
        return 'star';
    }
  }
}
