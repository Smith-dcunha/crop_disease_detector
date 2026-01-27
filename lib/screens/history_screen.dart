import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../models/scan_history.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<ScanHistory> _scans = [];
  String _filter = 'all'; // all, healthy, diseased
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    setState(() => _isLoading = true);

    try {
      List<ScanHistory> scans;

      if (_filter == 'all') {
        scans = await _dbService.getAllScans();
      } else if (_filter == 'healthy') {
        scans = await _dbService.getScansByFilter(isHealthy: true);
      } else {
        scans = await _dbService.getScansByFilter(isHealthy: false);
      }

      setState(() {
        _scans = scans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading scans: $e');
    }
  }

  Future<void> _deleteScan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Scan', style: AppTextStyles.h6),
        content: Text(
          AppStrings.deleteConfirm,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.deleteScan(id);
      _loadScans();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.scanDeleted),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _clearAllScans() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All History', style: AppTextStyles.h6),
        content: Text(
          AppStrings.clearAllConfirm,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(AppStrings.clearHistory),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.deleteAllScans();
      _loadScans();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.historyCleared),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.historyTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_scans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _clearAllScans,
              tooltip: AppStrings.clearHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),

          // Scan List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _scans.isEmpty
                ? _buildEmptyState()
                : _buildScanList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Text(
            '${AppStrings.filterBy}: ',
            style: AppTextStyles.labelBold,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', AppStrings.allScans),
                  const SizedBox(width: AppConstants.paddingSmall),
                  _buildFilterChip('diseased', AppStrings.diseased),
                  const SizedBox(width: AppConstants.paddingSmall),
                  _buildFilterChip('healthy', AppStrings.healthy),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
        _loadScans();
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildScanList() {
    return RefreshIndicator(
      onRefresh: _loadScans,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _scans.length,
        itemBuilder: (context, index) {
          final scan = _scans[index];
          return _buildScanCard(scan);
        },
      ),
    );
  }

  Widget _buildScanCard(ScanHistory scan) {
    final statusColor = scan.isHealthy ? AppColors.success : _getSeverityColor(scan.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () => _viewScanDetails(scan),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                child: File(scan.imagePath).existsSync()
                    ? Image.file(
                  File(scan.imagePath),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 80,
                  height: 80,
                  color: AppColors.borderLight,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: AppColors.textLight,
                  ),
                ),
              ),

              const SizedBox(width: AppConstants.paddingMedium),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease Name
                    Text(
                      scan.diseaseName,
                      style: AppTextStyles.h6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Confidence
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_rounded,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(scan.confidence * 100).toStringAsFixed(1)}% confidence',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          scan.getFormattedDate(),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete Button
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                onPressed: () => _deleteScan(scan.id!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 100,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              AppStrings.noHistory,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              AppStrings.startFirstScan,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low': return AppColors.severityLow;
      case 'medium': return AppColors.severityMedium;
      case 'high': return AppColors.severityHigh;
      case 'critical': return AppColors.severityCritical;
      default: return AppColors.severityLow;
    }
  }

  void _viewScanDetails(ScanHistory scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scan.diseaseName, style: AppTextStyles.h6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (File(scan.imagePath).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                child: Image.file(
                  File(scan.imagePath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text('Confidence: ${(scan.confidence * 100).toStringAsFixed(1)}%'),
            Text('Severity: ${scan.severity}'),
            Text('Status: ${scan.isHealthy ? "Healthy" : "Diseased"}'),
            Text('Date: ${_formatDate(scan.detectedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}