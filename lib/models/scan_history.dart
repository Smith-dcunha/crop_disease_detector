class ScanHistory {
  final int? id;
  final String diseaseName;
  final double confidence;
  final String severity;
  final bool isHealthy;
  final String imagePath;
  final DateTime detectedAt;
  final String? additionalInfo;

  ScanHistory({
    this.id,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.isHealthy,
    required this.imagePath,
    required this.detectedAt,
    this.additionalInfo,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'disease_name': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'is_healthy': isHealthy ? 1 : 0,
      'image_path': imagePath,
      'detected_at': detectedAt.toIso8601String(),
      'additional_info': additionalInfo,
    };
  }

  // Create from Map
  factory ScanHistory.fromMap(Map<String, dynamic> map) {
    return ScanHistory(
      id: map['id'] as int?,
      diseaseName: map['disease_name'] as String,
      confidence: map['confidence'] as double,
      severity: map['severity'] as String,
      isHealthy: (map['is_healthy'] as int) == 1,
      imagePath: map['image_path'] as String,
      detectedAt: DateTime.parse(map['detected_at'] as String),
      additionalInfo: map['additional_info'] as String?,
    );
  }

  // Get formatted date
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(detectedAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hr ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${detectedAt.day}/${detectedAt.month}/${detectedAt.year}';
    }
  }

  // Copy with method
  ScanHistory copyWith({
    int? id,
    String? diseaseName,
    double? confidence,
    String? severity,
    bool? isHealthy,
    String? imagePath,
    DateTime? detectedAt,
    String? additionalInfo,
  }) {
    return ScanHistory(
      id: id ?? this.id,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      severity: severity ?? this.severity,
      isHealthy: isHealthy ?? this.isHealthy,
      imagePath: imagePath ?? this.imagePath,
      detectedAt: detectedAt ?? this.detectedAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'ScanHistory(id: $id, disease: $diseaseName, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}