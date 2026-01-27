import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import 'analysis_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _captureImage() async {
    try {
      setState(() => _isLoading = true);

      // Check camera permission
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog();
          setState(() => _isLoading = false);
          return;
        }
      }

      // Capture image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: AppConstants.imageQuality,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: AppConstants.imageQuality,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _analyzeImage() {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(imageFile: _selectedImage!),
        ),
      );
    }
  }

  void _retakeImage() {
    setState(() => _selectedImage = null);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.cameraPermissionDenied,
          style: AppTextStyles.h6,
        ),
        content: Text(
          AppStrings.cameraPermissionRequired,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(AppStrings.settings),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: AppTextStyles.h6),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.cameraTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _selectedImage == null
          ? _buildCameraOptions()
          : _buildImagePreview(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildCameraOptions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.info,
                    size: AppConstants.iconLarge,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    AppStrings.captureGuidelines,
                    style: AppTextStyles.h6.copyWith(color: AppColors.info),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    AppStrings.cameraInstruction,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingXLarge),

            // Tips
            _buildTipItem(Icons.wb_sunny_rounded, AppStrings.tip1),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildTipItem(Icons.center_focus_strong_rounded, AppStrings.tip2),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildTipItem(Icons.camera_rounded, AppStrings.tip3),

            const Spacer(),

            // Camera Button
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeightLarge,
              child: ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(AppStrings.camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Gallery Button
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeightLarge,
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_rounded),
                label: Text(AppStrings.gallery),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppConstants.paddingSmall),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return SafeArea(
      child: Column(
        children: [
          // Image Preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retakeImage,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(AppStrings.retake),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _analyzeImage,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text('Analyze'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.paddingMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}