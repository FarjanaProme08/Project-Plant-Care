import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../providers/plant_provider.dart';
import '../services/care_guide_service.dart';
import 'add_edit_plant_screen.dart';
import 'care_guide_detail_screen.dart';
import 'growth_diary_screen.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantProvider>(
      builder: (context, provider, child) {
        final plant = provider.getPlantById(plantId);
        if (plant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Plant not found')),
          );
        }

        final history = provider.getHistory(plant.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(plant.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditPlantScreen(plant: plant),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, provider, plant.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (plant.imagePath != null)
                  Image.file(
                    File(plant.imagePath!),
                    height: 300,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.green.shade100,
                    child: const Icon(
                      Icons.local_florist,
                      size: 80,
                      color: Colors.green,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        plant.species,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(context, plant),
                      const SizedBox(height: 12),
                      _buildGrowthDiaryButton(context, plant),
                      const SizedBox(height: 12),
                      _buildCareGuideBanner(context, plant.species),
                      const SizedBox(height: 24),
                      Text(
                        'Care History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      if (history.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No care history recorded yet."),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final h = history[index];
                            return ListTile(
                              leading: Icon(
                                h.careType == 'Water'
                                    ? Icons.water_drop
                                    : h.careType == 'Mist'
                                    ? Icons.cloud
                                    : Icons.eco,
                                color: h.careType == 'Water'
                                    ? Colors.blue
                                    : h.careType == 'Mist'
                                    ? Colors.lightBlue
                                    : Colors.green,
                              ),
                              title: Text(h.careType),
                              subtitle: Text(
                                DateFormat.yMMMd().add_jm().format(h.timestamp),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrowthDiaryButton(BuildContext context, plant) {
    return Card(
      elevation: 0,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.photo_library, color: Colors.green),
        title: const Text(
          'Plant Growth Diary',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        subtitle: const Text('Track growth with photos and notes'),
        trailing: const Icon(Icons.chevron_right, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GrowthDiaryScreen(plant: plant),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, plant) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildIntervalRow(
              Icons.water_drop,
              'Water',
              plant.waterIntervalDays,
              plant.nextWaterDate,
            ),
            const Divider(),
            _buildIntervalRow(
              Icons.cloud,
              'Mist',
              plant.mistIntervalDays,
              plant.nextMistDate,
            ),
            const Divider(),
            _buildIntervalRow(
              Icons.eco,
              'Fertilize',
              plant.fertilizerIntervalDays,
              plant.nextFertilizerDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalRow(
    IconData icon,
    String label,
    int days,
    DateTime? nextDate,
  ) {
    if (days == 0 || nextDate == null) {
      return Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: Not scheduled',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    final isOverdue = nextDate.isBefore(DateTime.now());

    return Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label every $days days',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Next: ${DateFormat.yMMMd().format(nextDate)}',
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, PlantProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plant?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePlant(id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCareGuideBanner(BuildContext context, String species) {
    final service = CareGuideService();
    // We fire initState asynchronously but for this banner we do a synchronous
    // lookup — so we pre-load lazily. Wrap in FutureBuilder.
    return FutureBuilder<List<dynamic>>(
      future: service.loadOfflineGuides(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final guide = service.findForSpecies(species);
        if (guide == null) return const SizedBox.shrink();
        final cs = Theme.of(context).colorScheme;
        return Card(
          elevation: 0,
          color: cs.primaryContainer.withValues(alpha: 0.7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CareGuideDetailScreen(
                    guide: guide, service: service),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Text(guide.emoji,
                      style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View Care Guide',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          guide.commonName,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: cs.onPrimaryContainer),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
