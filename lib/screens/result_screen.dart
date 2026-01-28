import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../models/scan_history.dart';

class ResultScreen extends StatelessWidget {
  final ScanHistory scanHistory;
  final Map<String, dynamic> predictionResult;

  const ResultScreen({
    super.key,
    required this.scanHistory,
    required this.predictionResult,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = scanHistory.isHealthy;
    final confidence = scanHistory.confidence;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: isHealthy ? AppColors.success : AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingXLarge),
              decoration: BoxDecoration(
                gradient: isHealthy
                    ? AppColors.successGradient
                    : LinearGradient(
                  colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isHealthy ? Icons.check_circle : Icons.warning,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    isHealthy ? 'Healthy Crop!' : 'Disease Detected',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    scanHistory.diseaseName,
                    style: AppTextStyles.h5.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                    child: Image.file(
                      File(scanHistory.imagePath),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Confidence Card
                  _buildInfoCard(
                    'Confidence',
                    '${(confidence * 100).toStringAsFixed(1)}%',
                    Icons.analytics,
                    AppColors.primary,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Severity Card
                  _buildInfoCard(
                    'Severity',
                    scanHistory.severity,
                    Icons.speed,
                    _getSeverityColor(scanHistory.severity),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Recommendations
                  if (!isHealthy) _buildRecommendations(),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.home),
                          label: const Text('Home'),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Share functionality
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(icon, color: color, size: AppConstants.iconMedium),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.h5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.warning),
              const SizedBox(width: AppConstants.paddingSmall),
              Text('Recommendations', style: AppTextStyles.h6),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildRecommendationItem('Remove infected leaves immediately'),
          _buildRecommendationItem('Apply appropriate fungicide'),
          _buildRecommendationItem('Improve air circulation'),
          _buildRecommendationItem('Consult agricultural expert if severe'),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppColors.error;
      case 'moderate':
        return AppColors.warning;
      case 'mild':
        return AppColors.info;
      default:
        return AppColors.success;
    }
  }
}