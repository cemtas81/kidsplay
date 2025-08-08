import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfilePhotoSection extends StatefulWidget {
  final Function(XFile?) onPhotoSelected;
  final XFile? selectedPhoto;

  const ProfilePhotoSection({
    super.key,
    required this.onPhotoSelected,
    this.selectedPhoto,
  });

  @override
  State<ProfilePhotoSection> createState() => _ProfilePhotoSectionState();
}

class _ProfilePhotoSectionState extends State<ProfilePhotoSection> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _showCamera = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Silent fail - camera not available
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      // Ignore focus mode errors
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        // Ignore flash mode errors on web
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      widget.onPhotoSelected(photo);
      setState(() {
        _showCamera = false;
      });
    } catch (e) {
      // Handle capture error gracefully
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85);

      if (image != null) {
        widget.onPhotoSelected(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to select photo')));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                      color: AppTheme.lightTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 3.h),
              Text('Add Profile Photo',
                  style: AppTheme.lightTheme.textTheme.titleLarge),
              SizedBox(height: 3.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _buildPhotoOption(
                    icon: 'camera_alt',
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      if (_isCameraInitialized) {
                        setState(() {
                          _showCamera = true;
                        });
                      }
                    }),
                _buildPhotoOption(
                    icon: 'photo_library',
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                    }),
              ]),
              SizedBox(height: 4.h),
            ])));
  }

  Widget _buildPhotoOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 25.w,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3))),
            child: Column(children: [
              CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 32),
              SizedBox(height: 1.h),
              Text(label,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500)),
            ])));
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
          height: 40.h,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(16)),
          child: const Center(
              child: CircularProgressIndicator(color: Colors.white)));
    }

    return Container(
        height: 40.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CameraPreview(_cameraController!)),
          Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _showCamera = false;
                          });
                        },
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 32)),
                    GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4)),
                            child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle)))),
                    IconButton(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library,
                            color: Colors.white, size: 32)),
                  ])),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera) {
      return _buildCameraView();
    }

    return Column(children: [
      GestureDetector(
          onTap: _showPhotoOptions,
          child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
                      width: 2)),
              child: widget.selectedPhoto != null
                  ? ClipOval(
                      child: kIsWeb
                          ? Image.network(widget.selectedPhoto!.path,
                              fit: BoxFit.cover, width: 30.w, height: 30.w)
                          : CustomImageWidget(
                              imageUrl: widget.selectedPhoto!.path,
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          CustomIconWidget(
                              iconName: 'add_a_photo',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 32),
                          SizedBox(height: 1.h),
                          Text('Add Photo',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary)),
                        ]))),
      SizedBox(height: 2.h),
      Text('Tap to add your child\'s photo',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center),
    ]);
  }
}
