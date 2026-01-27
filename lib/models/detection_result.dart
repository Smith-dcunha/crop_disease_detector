class DetectionResult {
  final String diseaseName;
  final double confidence;
  final String severity;
  final bool isHealthy;
  final DateTime detectedAt;
  final String? additionalInfo;

  DetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.isHealthy,
    required this.detectedAt,
    this.additionalInfo,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'diseaseName': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'isHealthy': isHealthy,
      'detectedAt': detectedAt.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }

  // Create from JSON
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      diseaseName: json['diseaseName'] as String,
      confidence: json['confidence'] as double,
      severity: json['severity'] as String,
      isHealthy: json['isHealthy'] as bool,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      additionalInfo: json['additionalInfo'] as String?,
    );
  }

  // Get severity color
  String getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'low':
        return 'severityLow';
      case 'medium':
        return 'severityMedium';
      case 'high':
        return 'severityHigh';
      case 'critical':
        return 'severityCritical';
      default:
        return 'severityLow';
    }
  }

  // Get confidence level text
  String getConfidenceLevel() {
    if (confidence >= 0.85) {
      return 'Very High';
    } else if (confidence >= 0.7) {
      return 'High';
    } else if (confidence >= 0.5) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  @override
  String toString() {
    return 'DetectionResult(disease: $diseaseName, confidence: ${(confidence * 100).toStringAsFixed(1)}%, severity: $severity)';
  }
}