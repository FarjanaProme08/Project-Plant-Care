import 'dart:io';
import '../services/care_guide_service.dart';
import '../models/care_guide_entry.dart';

class AiService {
  final CareGuideService _careGuideService = CareGuideService();

  /// Mock Identifies a plant from an image file (Local version).
  Future<Map<String, String>> identifyPlant(File imageFile) async {
    // In a local/offline version without Vision API, we simulate a match 
    // or ask the user to use the search tool.
    return {
      'result': 'I am currently in Offline Mode. To identify this plant, please use the "Care Guide" search tool and compare your plant to the photos there. Expert Tip: Most indoor plants with large green leaves are Philodendrons or Monsteras!'
    };
  }

  /// Expert Chatbot for plant care advice (Local Rule-Based version).
  Future<String> getCareAdvice(String message, dynamic history) async {
    final query = message.toLowerCase();
    
    // 1. Check if the message mentions a plant in our guide
    final guides = await _careGuideService.loadOfflineGuides();
    CareGuideEntry? matchedPlant;
    
    for (var g in guides) {
      if (query.contains(g.commonName.toLowerCase()) || query.contains(g.species.toLowerCase())) {
        matchedPlant = g;
        break;
      }
    }

    // 2. Rule-based responses
    if (query.contains('water') || query.contains('how often')) {
      if (matchedPlant != null) {
        return 'For a ${matchedPlant.commonName}, you should water ${matchedPlant.wateringFrequency}. ${matchedPlant.instructions}';
      }
      return 'Most houseplants prefer to have the top inch of soil dry out before watering again. Stick your finger in the soil to check!';
    }

    if (query.contains('yellow') || query.contains('brown')) {
      return 'Yellow or brown leaves often indicate over-watering or poor drainage. Check the roots to ensure they aren\'t sitting in water.';
    }

    if (query.contains('sun') || query.contains('light')) {
      if (matchedPlant != null) {
        return 'The ${matchedPlant.commonName} thrives in ${matchedPlant.sunlightRequirements}.';
      }
      return 'Most indoor plants love bright, indirect light. Keep them near a window but away from harsh afternoon sun.';
    }

    if (matchedPlant != null) {
      return 'I found some info on the ${matchedPlant.commonName}! It is a ${matchedPlant.difficulty} plant. Tip: ${matchedPlant.instructions}';
    }

    return 'That\'s a great question! While I\'m offline, I can tell you that consistency is key for most plants. Would you like to know about watering, light, or common leaf problems?';
  }
}
