class DiseaseInfo {
  final String id;
  final String name;
  final String scientificName;
  final String category;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatments;
  final List<String> prevention;
  final String severity;
  final List<String> affectedCrops;
  final String imageUrl;
  final bool isCommon;

  DiseaseInfo({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatments,
    required this.prevention,
    required this.severity,
    required this.affectedCrops,
    required this.imageUrl,
    this.isCommon = false,
  });

  // Create from JSON
  factory DiseaseInfo.fromJson(Map<String, dynamic> json) {
    return DiseaseInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientific_name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      symptoms: List<String>.from(json['symptoms'] as List),
      causes: List<String>.from(json['causes'] as List),
      treatments: List<String>.from(json['treatments'] as List),
      prevention: List<String>.from(json['prevention'] as List),
      severity: json['severity'] as String,
      affectedCrops: List<String>.from(json['affected_crops'] as List),
      imageUrl: json['image_url'] as String? ?? '',
      isCommon: json['is_common'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'category': category,
      'description': description,
      'symptoms': symptoms,
      'causes': causes,
      'treatments': treatments,
      'prevention': prevention,
      'severity': severity,
      'affected_crops': affectedCrops,
      'image_url': imageUrl,
      'is_common': isCommon,
    };
  }

  // Get severity color
  String getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'high':
        return '#EF4444';
      case 'medium':
        return '#F59E0B';
      case 'low':
        return '#10B981';
      default:
        return '#6B7280';
    }
  }

  // Get category icon
  String getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'fungal':
        return '🍄';
      case 'bacterial':
        return '🦠';
      case 'viral':
        return '🧬';
      case 'pest':
        return '🐛';
      case 'nutritional':
        return '🌱';
      default:
        return '📋';
    }
  }
}