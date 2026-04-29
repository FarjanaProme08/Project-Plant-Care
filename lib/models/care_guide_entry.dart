import 'package:flutter/material.dart' show Color;

class CareGuideEntry {
  final String id;
  final String species;
  final String commonName;
  final String category;
  final String wateringFrequency;
  final String instructions;
  final String sunlightRequirements;
  final String humidity;
  final String soilType;
  final String toxicityWarnings;
  final String difficulty;
  final String emoji;

  const CareGuideEntry({
    required this.id,
    required this.species,
    required this.commonName,
    required this.category,
    required this.wateringFrequency,
    required this.instructions,
    required this.sunlightRequirements,
    required this.humidity,
    required this.soilType,
    required this.toxicityWarnings,
    required this.difficulty,
    required this.emoji,
  });

  factory CareGuideEntry.fromJson(Map<String, dynamic> json) {
    return CareGuideEntry(
      id: json['id'] as String,
      species: json['species'] as String,
      commonName: json['commonName'] as String,
      category: json['category'] as String,
      wateringFrequency: json['wateringFrequency'] as String,
      instructions: json['instructions'] as String,
      sunlightRequirements: json['sunlightRequirements'] as String,
      humidity: json['humidity'] as String,
      soilType: json['soilType'] as String,
      toxicityWarnings: json['toxicityWarnings'] as String,
      difficulty: json['difficulty'] as String,
      emoji: json['emoji'] as String,
    );
  }

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return species.toLowerCase().contains(q) ||
        commonName.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q);
  }

  bool matchesSpecies(String plantSpecies) {
    final q = plantSpecies.toLowerCase();
    return species.toLowerCase().contains(q) ||
        commonName.toLowerCase().contains(q) ||
        q.contains(species.toLowerCase()) ||
        q.contains(commonName.toLowerCase());
  }

  bool get isToxic =>
      !toxicityWarnings.toLowerCase().startsWith('non-toxic');

  Color get difficultyColor {
    switch (difficulty) {
      case 'Easy':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFFF9800);
      case 'Hard':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
