import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../models/disease_info.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseInfo disease;

  const DiseaseDetailScreen({
    super.key,
    required this.disease,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                disease.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        disease.getCategoryIcon(),
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        disease.scientificName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Severity
                  Row(
                    children: [
                      _buildInfoChip(
                        disease.category,
                        Icons.category,
                        AppColors.primary,
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      _buildSeverityChip(disease.severity),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  // Description
                  _buildSectionCard(
                    'About This Disease',
                    Icons.info_outline,
                    AppColors.info,
                    disease.description,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Symptoms
                  _buildListSection(
                    'Symptoms',
                    Icons.medical_information,
                    AppColors.error,
                    disease.symptoms,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Causes
                  _buildListSection(
                    'Causes',
                    Icons.science,
                    AppColors.warning,
                    disease.causes,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Treatments
                  _buildListSection(
                    'Treatment Methods',
                    Icons.healing,
                    AppColors.success,
                    disease.treatments,
                    important: true,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Prevention
                  _buildListSection(
                    'Prevention Tips',
                    Icons.shield,
                    AppColors.secondary,
                    disease.prevention,
                  ),

                  const SizedBox(height: AppConstants.paddingMedium),

                  // Affected Crops
                  _buildAffectedCropsSection(),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Share functionality
                            _showShareDialog(context);
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Save to favorites
                            _showSavedSnackBar(context);
                          },
                          icon: const Icon(Icons.bookmark),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String severity) {
    Color color;
    IconData icon;

    switch (severity.toLowerCase()) {
      case 'high':
        color = AppColors.error;
        icon = Icons.warning;
        break;
      case 'medium':
        color = AppColors.warning;
        icon = Icons.report_problem;
        break;
      case 'low':
        color = AppColors.success;
        icon = Icons.info;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$severity Severity',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      String title,
      IconData icon,
      Color color,
      String content,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(title, style: AppTextStyles.h6),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildListSection(
      String title,
      IconData icon,
      Color color,
      List<String> items, {
        bool important = false,
      }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: important ? color.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: important ? color.withOpacity(0.3) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(title, style: AppTextStyles.h6),
              if (important) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    'IMPORTANT',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAffectedCropsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture, color: AppColors.secondary, size: 24),
              const SizedBox(width: AppConstants.paddingSmall),
              Text('Affected Crops', style: AppTextStyles.h6),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: disease.affectedCrops.map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  crop,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Disease Info', style: AppTextStyles.h6),
        content: Text(
          'Share information about ${disease.name} with others.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSavedSnackBar(context);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showSavedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${disease.name} saved to favorites!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}