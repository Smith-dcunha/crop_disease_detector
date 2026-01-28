import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../models/scan_history.dart';
import '../services/database_service.dart';
import '../services/ml_service.dart';
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
  late Animation<double> _progressAnimation;

  bool _isAnalyzing = true;
  double _progress = 0.0;
  String _currentStep = 'Initializing AI model...';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });

    _animationController.forward();
    _analyzeImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    try {
      // Step 1: Initialize model
      await _updateStep('Initializing AI model...', 0.2);
      await MLService.initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Processing image
      await _updateStep('Processing image...', 0.5);
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 3: Running detection
      await _updateStep('Analyzing crop health...', 0.8);
      final result = await MLService.predictDisease(widget.imageFile);
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Complete
      await _updateStep('Analysis complete!', 1.0);
      await Future.delayed(const Duration(milliseconds: 500));

      // Save to database
      final scan = ScanHistory(
        diseaseName: result['diseaseName'],
        confidence: result['confidence'],
        severity: result['severity'],
        isHealthy: result['isHealthy'],
        imagePath: widget.imageFile.path,
        detectedAt: DateTime.now(),
        additionalInfo: _formatAdditionalInfo(result['topPredictions']),
      );

      await DatabaseService().insertScan(scan);

      // Navigate to results
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              scanHistory: scan,
              predictionResult: result,
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

  Future<void> _updateStep(String step, double targetProgress) async {
    setState(() {
      _currentStep = step;
    });
  }

  String _formatAdditionalInfo(List<dynamic> topPredictions) {
    return topPredictions
        .map((p) => '${p['label']}: ${(p['confidence'] * 100).toStringAsFixed(1)}%')
        .join('\n');
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analysis Failed', style: AppTextStyles.h6),
        content: Text(
          'Unable to analyze the image. Please try again.\n\nError: $error',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Preview
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingXLarge),

              // AI Icon
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Status Text
              Text(
                _currentStep,
                style: AppTextStyles.h5,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: AppColors.borderLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.paddingSmall),

              // Percentage
              Text(
                '${(_progress * 100).toInt()}%',
                style: AppTextStyles.h6.copyWith(color: AppColors.primary),
              ),

              const SizedBox(height: AppConstants.paddingXLarge),

              // Info Card
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: AppConstants.iconMedium,
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Our AI is analyzing your crop image using advanced deep learning algorithms',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}