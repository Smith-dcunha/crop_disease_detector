import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/disease_info.dart';

class EncyclopediaService {
  static List<DiseaseInfo>? _diseases;
  static Map<String, dynamic>? _categories;
  static bool _isInitialized = false;

  static const String dataPath = 'assets/data/disease_encyclopedia.json';

  /// Initialize encyclopedia data
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString(dataPath);
      final Map<String, dynamic> data = json.decode(jsonString);

      // Load diseases
      final List<dynamic> diseasesJson = data['diseases'] as List;
      _diseases = diseasesJson.map((json) => DiseaseInfo.fromJson(json)).toList();

      // Load categories
      _categories = {
        for (var category in data['categories'])
          category['id']: category
      };

      _isInitialized = true;
      print('✅ Encyclopedia loaded: ${_diseases!.length} diseases');
    } catch (e) {
      print('❌ Error loading encyclopedia: $e');
      throw Exception('Failed to load encyclopedia data: $e');
    }
  }

  /// Get all diseases
  static Future<List<DiseaseInfo>> getAllDiseases() async {
    if (!_isInitialized) await initialize();
    return _diseases ?? [];
  }

  /// Get disease by ID
  static Future<DiseaseInfo?> getDiseaseById(String id) async {
    if (!_isInitialized) await initialize();
    try {
      return _diseases?.firstWhere((disease) => disease.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get disease by name (fuzzy match)
  static Future<DiseaseInfo?> getDiseaseByName(String name) async {
    if (!_isInitialized) await initialize();

    final lowerName = name.toLowerCase();

    // Try exact match first
    try {
      return _diseases?.firstWhere(
            (disease) => disease.name.toLowerCase() == lowerName,
      );
    } catch (e) {
      // Try partial match
      try {
        return _diseases?.firstWhere(
              (disease) => disease.name.toLowerCase().contains(lowerName) ||
              lowerName.contains(disease.name.toLowerCase()),
        );
      } catch (e) {
        return null;
      }
    }
  }

  /// Search diseases by query
  static Future<List<DiseaseInfo>> searchDiseases(String query) async {
    if (!_isInitialized) await initialize();

    if (query.isEmpty) return getAllDiseases();

    final lowerQuery = query.toLowerCase();

    return _diseases?.where((disease) {
      return disease.name.toLowerCase().contains(lowerQuery) ||
          disease.scientificName.toLowerCase().contains(lowerQuery) ||
          disease.category.toLowerCase().contains(lowerQuery) ||
          disease.affectedCrops.any(
                (crop) => crop.toLowerCase().contains(lowerQuery),
          );
    }).toList() ?? [];
  }

  /// Get diseases by category
  static Future<List<DiseaseInfo>> getDiseasesByCategory(String category) async {
    if (!_isInitialized) await initialize();

    return _diseases?.where(
          (disease) => disease.category.toLowerCase() == category.toLowerCase(),
    ).toList() ?? [];
  }

  /// Get diseases by crop
  static Future<List<DiseaseInfo>> getDiseasesByCrop(String crop) async {
    if (!_isInitialized) await initialize();

    return _diseases?.where((disease) {
      return disease.affectedCrops.any(
            (c) => c.toLowerCase() == crop.toLowerCase(),
      );
    }).toList() ?? [];
  }

  /// Get diseases by severity
  static Future<List<DiseaseInfo>> getDiseasesBySeverity(String severity) async {
    if (!_isInitialized) await initialize();

    return _diseases?.where(
          (disease) => disease.severity.toLowerCase() == severity.toLowerCase(),
    ).toList() ?? [];
  }

  /// Get common diseases
  static Future<List<DiseaseInfo>> getCommonDiseases() async {
    if (!_isInitialized) await initialize();

    return _diseases?.where((disease) => disease.isCommon).toList() ?? [];
  }

  /// Get all categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    if (!_isInitialized) await initialize();
    return _categories?.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList() ?? [];

  }

  /// Get affected crops list (unique)
  static Future<List<String>> getAffectedCrops() async {
    if (!_isInitialized) await initialize();

    final Set<String> crops = {};
    _diseases?.forEach((disease) {
      crops.addAll(disease.affectedCrops);
    });

    final list = crops.toList();
    list.sort();
    return list;
  }

  /// Get statistics
  static Future<Map<String, int>> getStatistics() async {
    if (!_isInitialized) await initialize();

    int fungal = 0, bacterial = 0, viral = 0, pest = 0, nutritional = 0;
    int high = 0, medium = 0, low = 0;

    _diseases?.forEach((disease) {
      // Count by category
      switch (disease.category.toLowerCase()) {
        case 'fungal':
          fungal++;
          break;
        case 'bacterial':
          bacterial++;
          break;
        case 'viral':
          viral++;
          break;
        case 'pest':
          pest++;
          break;
        case 'nutritional':
          nutritional++;
          break;
      }

      // Count by severity
      switch (disease.severity.toLowerCase()) {
        case 'high':
          high++;
          break;
        case 'medium':
          medium++;
          break;
        case 'low':
          low++;
          break;
      }
    });

    return {
      'total': _diseases?.length ?? 0,
      'fungal': fungal,
      'bacterial': bacterial,
      'viral': viral,
      'pest': pest,
      'nutritional': nutritional,
      'high_severity': high,
      'medium_severity': medium,
      'low_severity': low,
    };
  }
}