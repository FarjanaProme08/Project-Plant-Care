import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/care_guide_entry.dart';
import '../providers/plant_provider.dart';
import '../services/care_guide_service.dart';
import 'care_guide_detail_screen.dart';

class CareGuideScreen extends StatefulWidget {
  const CareGuideScreen({super.key});

  @override
  State<CareGuideScreen> createState() => _CareGuideScreenState();
}

class _CareGuideScreenState extends State<CareGuideScreen>
    with SingleTickerProviderStateMixin {
  final CareGuideService _service = CareGuideService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<CareGuideEntry> _allGuides = [];
  List<CareGuideEntry> _filtered = [];
  List<WikiPlantInfo?> _wikiResults = [];

  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  bool _loading = true;
  bool _searchingOnline = false;
  String _searchQuery = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final guides = await _service.loadOfflineGuides();
    final cats = ['All', ..._service.categories];
    setState(() {
      _allGuides = guides;
      _filtered = guides;
      _categories = cats;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _applyFilter(query);
      if (query.trim().length >= 3) _doOnlineSearch(query.trim());
    });
  }

  void _applyFilter(String query) {
    final byCategory = _selectedCategory == 'All'
        ? _allGuides
        : _service.getByCategory(_selectedCategory);
    setState(() {
      _searchQuery = query;
      _filtered = query.trim().isEmpty
          ? byCategory
          : byCategory.where((e) => e.matchesQuery(query)).toList();
      if (query.trim().isEmpty) _wikiResults = [];
    });
  }

  void _onCategoryTap(String cat) {
    setState(() => _selectedCategory = cat);
    _applyFilter(_searchQuery);
  }

  Future<void> _doOnlineSearch(String query) async {
    setState(() => _searchingOnline = true);
    final wiki = await _service.fetchWikiInfo(query);
    if (!mounted) return;
    setState(() {
      _wikiResults = wiki != null ? [wiki] : [];
      _searchingOnline = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme),
          SliverToBoxAdapter(child: _buildSearchBar(colorScheme)),
          SliverToBoxAdapter(child: _buildCategoryChips(colorScheme)),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildMyPlantsSection(colorScheme),
            if (_searchQuery.trim().length >= 3)
              _buildOnlineResultsSection(colorScheme),
            _buildOfflineGuidesList(colorScheme),
          ],
        ],
      ),
    );
  }

  // ─── Sliver AppBar ────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            const Icon(Icons.menu_book, size: 20),
            const SizedBox(width: 8),
            Text(
              'Plant Care Guide',
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary,
                cs.primary.withValues(alpha: 0.75),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -20,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(Icons.local_florist,
                      size: 200, color: cs.onPrimary),
                ),
              ),
              Positioned(
                left: -20,
                bottom: 30,
                child: Opacity(
                  opacity: 0.08,
                  child:
                      Icon(Icons.eco, size: 150, color: cs.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search plants (offline + online)…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchingOnline
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _applyFilter('');
                      },
                    )
                  : null,
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // ─── Category Chips ───────────────────────────────────────────────────────

  Widget _buildCategoryChips(ColorScheme cs) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = cat == _selectedCategory;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => _onCategoryTap(cat),
            selectedColor: cs.primary,
            labelStyle: TextStyle(
              color: selected ? cs.onPrimary : cs.onSurface,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  // ─── My Plants Section ────────────────────────────────────────────────────

  Widget _buildMyPlantsSection(ColorScheme cs) {
    final plants = context.watch<PlantProvider>().plants;
    if (plants.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final matched = <Map<String, dynamic>>[];
    for (final plant in plants) {
      final guide = _service.findForSpecies(plant.species);
      if (guide != null) matched.add({'plant': plant, 'guide': guide});
    }
    if (matched.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              children: [
                Icon(Icons.yard, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'My Plants — Quick Guide',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: matched.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final item = matched[i];
                final guide = item['guide'] as CareGuideEntry;
                final plant = item['plant'];
                return GestureDetector(
                  onTap: () => _openDetail(guide),
                  child: Container(
                    width: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer,
                          cs.primaryContainer.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: cs.primary.withValues(alpha: 0.3), width: 1),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(guide.emoji,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          plant.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          guide.commonName,
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.6)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.water_drop,
                                size: 12, color: Colors.blue.shade400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                guide.wateringFrequency,
                                style: const TextStyle(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
        ],
      ),
    );
  }

  // ─── Online Results Section ───────────────────────────────────────────────

  Widget _buildOnlineResultsSection(ColorScheme cs) {
    if (_searchingOnline) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(width: 16),
              SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('Searching Wikipedia…',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      );
    }
    if (_wikiResults.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final wiki = _wikiResults.first!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Card(
          elevation: 0,
          color: cs.tertiaryContainer.withValues(alpha: 0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.public, size: 16, color: cs.tertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Online Result — Wikipedia',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  wiki.title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  wiki.extract.length > 300
                      ? '${wiki.extract.substring(0, 300)}…'
                      : wiki.extract,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                if (wiki.imageUrl != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      wiki.imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Offline Guides List ──────────────────────────────────────────────────

  Widget _buildOfflineGuidesList(ColorScheme cs) {
    if (_filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 60, color: cs.outline),
              const SizedBox(height: 12),
              Text('No plants found',
                  style: TextStyle(color: cs.outline, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Try a different name or category',
                  style:
                      TextStyle(color: cs.outline.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.offline_bolt, size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Offline Library (${_filtered.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              );
            }
            final guide = _filtered[i - 1];
            return _GuideCard(guide: guide, onTap: () => _openDetail(guide));
          },
          childCount: _filtered.length + 1,
        ),
      ),
    );
  }

  void _openDetail(CareGuideEntry guide) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CareGuideDetailScreen(guide: guide, service: _service),
      ),
    );
  }
}

// ─── Reusable Guide Card ─────────────────────────────────────────────────────

class _GuideCard extends StatelessWidget {
  final CareGuideEntry guide;
  final VoidCallback onTap;

  const _GuideCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(guide.emoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.commonName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      guide.species,
                      style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _chip(guide.category, cs.secondaryContainer,
                            cs.onSecondaryContainer),
                        _chip(guide.difficulty, guide.difficultyColor,
                            Colors.white),
                        if (guide.isToxic)
                          _chip('⚠️ Toxic', Colors.orange.shade100,
                              Colors.orange.shade900),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.water_drop,
                            size: 13, color: Colors.blue.shade400),
                        const SizedBox(width: 4),
                        Text(
                          guide.wateringFrequency,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.wb_sunny,
                            size: 13, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            guide.sunlightRequirements,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
      );
}
