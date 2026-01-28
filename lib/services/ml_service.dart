import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';

class MLService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool _isInitialized = false;
  static bool _useTestMode = false; // Fallback mode

  // Model configuration
  static const String modelPath = 'assets/models/plant_disease_model.tflite';
  static const String labelsPath = 'assets/data/labels.json';
  static const int inputSize = 224;

  /// Initialize the ML model
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to load model
      _interpreter = await Interpreter.fromAsset(modelPath);
      print('✅ Model loaded successfully');

      // Try to load labels
      final labelsData = await rootBundle.loadString(labelsPath);
      final labelsJson = json.decode(labelsData);
      _labels = List<String>.from(labelsJson['classes']);
      print('✅ Labels loaded: ${_labels!.length} classes');

      _isInitialized = true;
      _useTestMode = false;
    } catch (e) {
      print('⚠️ ML Model not found, using test mode');
      print('Error: $e');

      // Enable test mode with dummy data
      _useTestMode = true;
      _isInitialized = true;

      // Create dummy labels for testing
      _labels = [
        'Tomato Early Blight',
        'Tomato Late Blight',
        'Tomato Healthy',
        'Potato Early Blight',
        'Corn Common Rust',
      ];
    }
  }

  /// Predict disease from image file
  static Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    // If in test mode, return dummy data
    if (_useTestMode) {
      return _getDummyPrediction();
    }

    try {
      // Read and preprocess image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image
      final resizedImage = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
      );

      // Convert to input tensor (normalized 0-1)
      final input = _imageToByteListFloat32(resizedImage);

      // Prepare output
      final output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Get predictions
      final predictions = output[0] as List<double>;

      // Find top prediction
      double maxConfidence = predictions[0];
      int maxIndex = 0;

      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxConfidence) {
          maxConfidence = predictions[i];
          maxIndex = i;
        }
      }

      // Get disease name and clean it
      String diseaseName = _labels![maxIndex];
      bool isHealthy = diseaseName.toLowerCase().contains('healthy');

      // Determine severity
      String severity = _calculateSeverity(maxConfidence, isHealthy);

      // Get top 3 predictions for additional info
      List<Map<String, dynamic>> topPredictions = [];
      for (int i = 0; i < predictions.length; i++) {
        topPredictions.add({
          'label': _labels![i],
          'confidence': predictions[i],
        });
      }
      topPredictions.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
      topPredictions = topPredictions.take(3).toList();

      return {
        'diseaseName': _formatDiseaseName(diseaseName),
        'confidence': maxConfidence,
        'severity': severity,
        'isHealthy': isHealthy,
        'topPredictions': topPredictions,
        'allPredictions': predictions,
        'testMode': false,
      };
    } catch (e) {
      print('❌ Prediction error: $e');

      // Return dummy data instead of crashing
      print('⚠️ Returning test prediction due to error');
      return _getDummyPrediction();
    }
  }

  /// Get dummy prediction for testing
  static Map<String, dynamic> _getDummyPrediction() {
    // Simulate a disease detection for testing
    final diseases = [
      {'name': 'Tomato Early Blight', 'confidence': 0.87, 'healthy': false},
      {'name': 'Tomato Healthy', 'confidence': 0.92, 'healthy': true},
      {'name': 'Potato Late Blight', 'confidence': 0.78, 'healthy': false},
      {'name': 'Corn Common Rust', 'confidence': 0.65, 'healthy': false},
    ];

    // Pick a random one
    final selected = diseases[DateTime.now().second % diseases.length];

    return {
      'diseaseName': selected['name'],
      'confidence': selected['confidence'],
      'severity': _calculateSeverity(selected['confidence'] as double, selected['healthy'] as bool),
      'isHealthy': selected['healthy'],
      'topPredictions': [
        {'label': selected['name'], 'confidence': selected['confidence']},
        {'label': 'Tomato Septoria Leaf Spot', 'confidence': 0.08},
        {'label': 'Tomato Leaf Mold', 'confidence': 0.05},
      ],
      'testMode': true,
    };
  }

  /// Convert image to Float32 byte list (normalized 0-1)
  static Float32List _imageToByteListFloat32(img.Image image) {
    final convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = img.getRed(pixel) / 255.0;
        buffer[pixelIndex++] = img.getGreen(pixel) / 255.0;
        buffer[pixelIndex++] = img.getBlue(pixel) / 255.0;
      }
    }

    return convertedBytes;

  }

  /// Calculate severity based on confidence
  static String _calculateSeverity(double confidence, bool isHealthy) {
    if (isHealthy) return 'Healthy';

    if (confidence >= 0.9) return 'Severe';
    if (confidence >= 0.7) return 'Moderate';
    return 'Mild';
  }

  /// Format disease name for display
  static String _formatDiseaseName(String rawName) {
    // Remove underscores and capitalize
    return rawName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Check if using test mode
  static bool get isTestMode => _useTestMode;

  /// Dispose resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _isInitialized = false;
  }
}