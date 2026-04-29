import 'package:flutter/material.dart';
import '../models/care_guide_entry.dart';
import '../services/care_guide_service.dart';

class CareGuideDetailScreen extends StatefulWidget {
  final CareGuideEntry guide;
  final CareGuideService service;

  const CareGuideDetailScreen({
    super.key,
    required this.guide,
    required this.service,
  });

  @override
  State<CareGuideDetailScreen> createState() => _CareGuideDetailScreenState();
}

class _CareGuideDetailScreenState extends State<CareGuideDetailScreen> {
  WikiPlantInfo? _wiki;
  bool _loadingWiki = true;

  @override
  void initState() {
    super.initState();
    _fetchWiki();
  }

  Future<void> _fetchWiki() async {
    final info = await widget.service.fetchWikiInfo(
      '${widget.guide.commonName} plant',
    );
    if (!mounted) return;
    setState(() {
      _wiki = info;
      _loadingWiki = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.guide;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero AppBar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                g.commonName,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: _wiki?.imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _wiki!.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _gradientBg(cs, g.emoji),
                        ),
                        Container(color: Colors.black38),
                      ],
                    )
                  : _gradientBg(cs, g.emoji),
            ),
          ),

          // ─── Content ───────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Species + badges
                Text(
                  g.species,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _badge(g.category, cs.secondaryContainer,
                        cs.onSecondaryContainer),
                    _badge(
                      g.difficulty,
                      g.difficultyColor,
                      Colors.white,
                    ),
                    if (g.isToxic)
                      _badge('⚠️ Toxic to Pets',
                          Colors.orange.shade100, Colors.orange.shade900),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Care Cards ───────────────────────────────────────────
                _sectionTitle(context, '🌿 Care Instructions'),
                _infoCard(
                  context,
                  children: [
                    _row(Icons.water_drop, 'Watering', g.wateringFrequency,
                        Colors.blue),
                    _divider(),
                    _row(Icons.description, 'Details', g.instructions,
                        cs.primary),
                  ],
                ),
                const SizedBox(height: 16),

                _sectionTitle(context, '☀️ Light & Environment'),
                _infoCard(
                  context,
                  children: [
                    _row(Icons.wb_sunny, 'Sunlight', g.sunlightRequirements,
                        Colors.amber.shade700),
                    _divider(),
                    _row(Icons.water, 'Humidity', g.humidity,
                        Colors.lightBlue),
                    _divider(),
                    _row(Icons.grass, 'Soil', g.soilType,
                        Colors.brown.shade400),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Toxicity ─────────────────────────────────────────────
                _sectionTitle(context, '⚠️ Safety & Toxicity'),
                Card(
                  elevation: 0,
                  color: g.isToxic
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: g.isToxic
                          ? Colors.orange.shade200
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          g.isToxic
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle,
                          color: g.isToxic
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            g.toxicityWarnings,
                            style: TextStyle(
                              fontSize: 14,
                              color: g.isToxic
                                  ? Colors.orange.shade900
                                  : Colors.green.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Wikipedia Section ─────────────────────────────────────
                _sectionTitle(context, '🌐 More Info (Online)'),
                if (_loadingWiki)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Fetching from Wikipedia…',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  )
                else if (_wiki == null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: cs.outline),
                        const SizedBox(width: 10),
                        const Text(
                          'No internet connection.\nOnly offline data shown.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  Card(
                    elevation: 0,
                    color: cs.tertiaryContainer.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.public,
                                  size: 16, color: cs.tertiary),
                              const SizedBox(width: 6),
                              Text(
                                'Wikipedia',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: cs.tertiary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _wiki!.extract.length > 600
                                ? '${_wiki!.extract.substring(0, 600)}…'
                                : _wiki!.extract,
                            style:
                                const TextStyle(fontSize: 13, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _gradientBg(ColorScheme cs, String emoji) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 80)),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      );

  Widget _sectionTitle(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _infoCard(BuildContext context,
          {required List<Widget> children}) =>
      Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(children: children),
        ),
      );

  Widget _divider() => const Divider(height: 16);

  Widget _row(IconData icon, String label, String value, Color iconColor) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(value,
                      style:
                          const TextStyle(fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );
}
