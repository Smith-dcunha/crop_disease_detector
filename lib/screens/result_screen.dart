import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../models/detection_result.dart';
import '../models/scan_history.dart';
import '../services/database_service.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final DetectionResult result;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _autoSaveScan();
  }

  Future<void> _autoSaveScan() async {
    try {
      final scan = ScanHistory(
        diseaseName: widget.result.diseaseName,
        confidence: widget.result.confidence,
        severity: widget.result.severity,
        isHealthy: widget.result.isHealthy,
        imagePath: widget.imageFile.path,
        detectedAt: widget.result.detectedAt,
        additionalInfo: widget.result.additionalInfo,
      );

      await _dbService.insertScan(scan);
      setState(() => _isSaved = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.scanSaved),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving scan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.resultsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareResult,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Card
            _buildImageCard(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Result Card
            _buildResultCard(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Confidence Card
            _buildConfidenceCard(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: AppConstants.paddingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingLarge),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Image.file(
          widget.imageFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isHealthy = widget.result.isHealthy;
    final statusColor = isHealthy ? AppColors.success : _getSeverityColor();
    final statusIcon = isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, size: 48, color: statusColor),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Status Text
          Text(
            isHealthy ? AppStrings.healthyCrop : AppStrings.diseaseDetected,
            style: AppTextStyles.h6.copyWith(color: AppColors.textSecondary),
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Disease Name
          Text(
            widget.result.diseaseName,
            style: AppTextStyles.diseaseName,
            textAlign: TextAlign.center,
          ),

          if (!isHealthy) ...[
            const SizedBox(height: AppConstants.paddingMedium),

            // Severity Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    '${AppStrings.severity}: ${widget.result.severity.toUpperCase()}',
                    style: AppTextStyles.labelBold.copyWith(color: statusColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(AppStrings.confidence, style: AppTextStyles.h6),

          const SizedBox(height: AppConstants.paddingMedium),

          // Confidence Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: widget.result.confidence,
                  strokeWidth: 12,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(widget.result.confidence * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.confidenceScore,
                  ),
                  Text(
                    widget.result.getConfidenceLevel(),
                    style: AppTextStyles.confidenceLabel,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Detection Time
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${AppStrings.detectedOn} ${_formatDate(widget.result.detectedAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Column(
        children: [
          if (!widget.result.isHealthy)
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeightLarge,
              child: ElevatedButton.icon(
                onPressed: _viewTreatment,
                icon: const Icon(Icons.medical_services_rounded),
                label: Text(AppStrings.viewTreatment),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),

          const SizedBox(height: AppConstants.paddingMedium),

          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeightLarge,
            child: OutlinedButton.icon(
              onPressed: _scanAnother,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(AppStrings.scanAnother),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor() {
    switch (widget.result.severity.toLowerCase()) {
      case 'low': return AppColors.severityLow;
      case 'medium': return AppColors.severityMedium;
      case 'high': return AppColors.severityHigh;
      case 'critical': return AppColors.severityCritical;
      default: return AppColors.severityLow;
    }
  }

  Color _getConfidenceColor() {
    if (widget.result.confidence >= 0.85) return AppColors.success;
    if (widget.result.confidence >= 0.7) return AppColors.info;
    if (widget.result.confidence >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _viewTreatment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Treatment details coming in next update!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _shareResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _scanAnother() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}