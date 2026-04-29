import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import '../models/care_guide_entry.dart';

/// Loads the bundled offline JSON and provides search helpers.
/// Online search uses the Wikipedia REST API — no API key required.
class CareGuideService {
  static const String _assetPath = 'assets/data/care_guide.json';

  List<CareGuideEntry> _offlineGuides = [];
  bool _loaded = false;

  // ─── Offline ──────────────────────────────────────────────────────────────

  Future<List<CareGuideEntry>> loadOfflineGuides() async {
    if (_loaded) return _offlineGuides;
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final List<dynamic> data = json.decode(raw) as List<dynamic>;
      _offlineGuides = data
          .map((e) => CareGuideEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _loaded = true;
    } catch (_) {
      _offlineGuides = [];
    }
    return _offlineGuides;
  }

  List<CareGuideEntry> searchOffline(String query) {
    if (query.trim().isEmpty) return _offlineGuides;
    return _offlineGuides
        .where((e) => e.matchesQuery(query.trim()))
        .toList();
  }

  CareGuideEntry? findForSpecies(String speciesName) {
    if (speciesName.trim().isEmpty) return null;
    try {
      return _offlineGuides.firstWhere(
        (e) => e.matchesSpecies(speciesName.trim()),
      );
    } catch (_) {
      return null;
    }
  }

  List<CareGuideEntry> getByCategory(String category) =>
      _offlineGuides.where((e) => e.category == category).toList();

  List<String> get categories =>
      (_offlineGuides.map((e) => e.category).toSet().toList()..sort());

  // ─── Online (Wikipedia) ───────────────────────────────────────────────────

  /// Fetches a Wikipedia summary for [plantName]. Returns null on failure.
  Future<WikiPlantInfo?> fetchWikiInfo(String plantName) async {
    try {
      final encoded = Uri.encodeComponent(plantName);
      final url =
          'https://en.wikipedia.org/api/rest_v1/page/summary/$encoded';
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'PlantCareApp/1.0 (flutter)');
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      final map = json.decode(body) as Map<String, dynamic>;
      final type = map['type'] as String? ?? '';
      if (type.contains('not_found') || type == 'disambiguation') return null;
      return WikiPlantInfo(
        title: map['title'] as String? ?? plantName,
        extract: map['extract'] as String? ?? '',
        imageUrl:
            (map['thumbnail'] as Map<String, dynamic>?)?['source'] as String?,
        wikiUrl:
            ((map['content_urls'] as Map<String, dynamic>?)?['desktop']
                    as Map<String, dynamic>?)?['page'] as String? ??
                '',
      );
    } catch (_) {
      return null;
    }
  }
}

class WikiPlantInfo {
  final String title;
  final String extract;
  final String? imageUrl;
  final String wikiUrl;

  const WikiPlantInfo({
    required this.title,
    required this.extract,
    this.imageUrl,
    required this.wikiUrl,
  });
}
