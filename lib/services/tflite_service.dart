import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/detection_result.dart';
import '../constants/app_constants.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;

  // Singleton pattern
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  /// Initialize the TFLite model and labels
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset(
        AppConstants.modelPath,
        options: InterpreterOptions()..threads = AppConstants.numThreads,
      );

      // Load labels
      final labelsData = await rootBundle.loadString(AppConstants.labelsPath);
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();

      _isInitialized = true;
      print('TFLite model initialized successfully');
      print('Model input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Model output shape: ${_interpreter!.getOutputTensor(0).shape}');
      print('Loaded ${_labels!.length} labels');
    } catch (e) {
      print('Error initializing TFLite model: $e');
      throw Exception('Failed to initialize model: $e');
    }
  }

  /// Detect disease from image file
  Future<DetectionResult> detectDisease(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Read and decode image
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Preprocess image
      final processedImage = _preprocessImage(image);

      // Run inference
      final output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);
      _interpreter!.run(processedImage, output);

      // Get predictions
      final predictions = output[0] as List<double>;

      // Find the class with highest confidence
      int maxIndex = 0;
      double maxConfidence = predictions[0];
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          maxIndex = i;
        }
      }

      // Get disease name
      final diseaseName = _labels![maxIndex];
      final isHealthy = diseaseName.toLowerCase().contains('healthy');

      // Determine severity based on confidence and disease type
      final severity = _determineSeverity(diseaseName, maxConfidence);

      return DetectionResult(
        diseaseName: diseaseName,
        confidence: maxConfidence,
        severity: severity,
        isHealthy: isHealthy,
        detectedAt: DateTime.now(),
        additionalInfo: null,
      );
    } catch (e) {
      print('Error during disease detection: $e');
      throw Exception('Detection failed: $e');
    }
  }

  /// Preprocess image for model input
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image to model input size
    final resizedImage = img.copyResize(
      image,
      width: AppConstants.inputImageSize,
      height: AppConstants.inputImageSize,
    );

    // Convert to 4D array [1, height, width, 3]
    final input = List.generate(
      1,
          (b) => List.generate(
        AppConstants.inputImageSize,
            (y) => List.generate(
          AppConstants.inputImageSize,
              (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              (img.getRed(pixel) - AppConstants.meanValue) / AppConstants.stdValue,
              (img.getGreen(pixel) - AppConstants.meanValue) / AppConstants.stdValue,
              (img.getBlue(pixel) - AppConstants.meanValue) / AppConstants.stdValue,
            ];
          },
        ),
      ),
    );

    return input;
  }

  /// Determine severity based on disease type and confidence
  String _determineSeverity(String diseaseName, double confidence) {
    if (diseaseName.toLowerCase().contains('healthy')) {
      return 'none';
    }

    // Critical diseases
    if (diseaseName.toLowerCase().contains('blight') ||
        diseaseName.toLowerCase().contains('wilt') ||
        diseaseName.toLowerCase().contains('rot')) {
      if (confidence > 0.8) return 'critical';
      if (confidence > 0.6) return 'high';
      return 'medium';
    }

    // Moderate diseases
    if (diseaseName.toLowerCase().contains('spot') ||
        diseaseName.toLowerCase().contains('mold') ||
        diseaseName.toLowerCase().contains('rust')) {
      if (confidence > 0.8) return 'high';
      if (confidence > 0.6) return 'medium';
      return 'low';
    }

    // Default severity based on confidence
    if (confidence > 0.8) return 'high';
    if (confidence > 0.6) return 'medium';
    return 'low';
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}