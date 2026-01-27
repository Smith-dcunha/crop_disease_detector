import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../services/tflite_service.dart';
import '../models/detection_result.dart';
import 'result_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final File imageFile;

  const AnalysisScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _statusText = AppStrings.analyzing;
  int _currentStep = 0;

  final List<String> _steps = [
    AppStrings.processingImage,
    AppStrings.detectingDisease,
    AppStrings.almostDone,
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startAnalysis();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startAnalysis() async {
    // Update status text periodically
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentStep = i;
          _statusText = _steps[i];
        });
      }
    }

    // Perform actual detection
    await _performDetection();
  }

  Future<void> _performDetection() async {
    try {
      final tfliteService = TFLiteService();
      await tfliteService.initialize();

      final result = await tfliteService.detectDisease(widget.imageFile);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageFile: widget.imageFile,
              result: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: AppTextStyles.h6),
        content: Text(
          'Failed to analyze image: $error',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Image Preview
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusXLarge,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusXLarge,
                    ),
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingXLarge * 2),

              // Loading Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.eco_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Status Text
              Text(
                _statusText,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Progress Steps
              _buildProgressSteps(),

              const Spacer(),

              // Please Wait Text
              Text(
                AppStrings.pleaseWait,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
      ),
    );
  }
}