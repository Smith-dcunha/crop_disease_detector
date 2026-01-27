import 'package:flutter/material.dart';

/// App Constants - Dimensions, Durations, and Values
class AppConstants {
  // Padding & Margins
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 100.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration scanningDuration = Duration(seconds: 2);

  // Image Sizes
  static const double imageThumbSize = 60.0;
  static const double imageSmallSize = 100.0;
  static const double imageMediumSize = 200.0;
  static const double imageLargeSize = 300.0;

  // List Item Heights
  static const double listItemHeight = 80.0;
  static const double gridItemHeight = 120.0;

  // Max Widths
  static const double maxContentWidth = 600.0;
  static const double maxImageSize = 1024.0;

  // Confidence Thresholds
  static const double confidenceThresholdLow = 0.5;
  static const double confidenceThresholdMedium = 0.7;
  static const double confidenceThresholdHigh = 0.85;

  // Model Settings
  static const int inputImageSize = 224; // TensorFlow Lite model input size
  static const int numThreads = 4;       // Number of threads for inference
  static const double meanValue = 127.5;  // Normalization mean
  static const double stdValue = 127.5;   // Normalization std

  // Database
  static const String databaseName = 'crop_disease_db.db';
  static const int databaseVersion = 1;
  static const String tableScans = 'scans';
  static const String tableDiseases = 'diseases';
  static const String tableTreatments = 'treatments';

  // SharedPreferences Keys
  static const String keyFirstTime = 'first_time';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifications = 'notifications';
  static const String keyUserId = 'user_id';
  static const String keyLastSync = 'last_sync';

  // File Paths
  static const String modelPath = 'assets/models/crop_disease_model.tflite';
  static const String labelsPath = 'assets/models/labels.txt';
  static const String diseasesDataPath = 'assets/data/diseases_database.json';
  static const String treatmentsDataPath = 'assets/data/treatments.json';

  // API Endpoints (if needed later)
  static const String baseUrl = 'https://api.cropcare.com';
  static const String apiVersion = '/v1';

  // Crop Types
  static const List<String> supportedCrops = [
    'Tomato',
    'Potato',
    'Corn',
    'Wheat',
    'Rice',
    'Apple',
    'Grape',
    'Pepper',
  ];

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'mr', 'name': 'मराठी'},
    {'code': 'te', 'name': 'తెలుగు'},
    {'code': 'ta', 'name': 'தமிழ்'},
  ];

  // Severity Levels
  static const String severityLow = 'low';
  static const String severityMedium = 'medium';
  static const String severityHigh = 'high';
  static const String severityCritical = 'critical';

  // Image Quality
  static const int imageQuality = 85;
  static const int thumbnailQuality = 60;

  // Pagination
  static const int itemsPerPage = 20;
  static const int historyLimit = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(days: 7);

  // Network Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Error Retry
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Notification IDs
  static const int notificationIdScanComplete = 1;
  static const int notificationIdDiseaseAlert = 2;
  static const int notificationIdTip = 3;
}