import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/plant_provider.dart';
import 'plant_list_screen.dart';
import 'care_guide_screen.dart';
import 'add_edit_plant_screen.dart';
import 'plant_detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Care Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlantProvider>(
        builder: (context, provider, child) {
          final tasks = provider.getUpcomingTasks();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSummary(context, provider),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildUpcomingTasks(context, tasks),
                const SizedBox(height: 24),
                _buildMyPlants(context, provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPlantScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsSummary(
    BuildContext context,
    PlantProvider provider,
  ) {
    int tasksDoneToday = 0;
    final now = DateTime.now();
    for (var plant in provider.plants) {
      final history = provider.getHistory(plant.id);
      tasksDoneToday += history
          .where(
            (h) =>
                h.timestamp.year == now.year &&
                h.timestamp.month == now.month &&
                h.timestamp.day == now.day,
          )
          .length;
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Gardener! 🌿',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.plants.length} Plants • $tasksDoneToday Tasks Today',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionCard(
          context,
          icon: Icons.local_florist,
          label: 'My Plants',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlantListScreen()),
          ),
        ),
        _buildActionCard(
          context,
          icon: Icons.menu_book,
          label: 'Care Guide',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CareGuideScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Theme.of(context).primaryColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTasks(
    BuildContext context,
    List<Map<String, dynamic>> tasks,
  ) {
    if (tasks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text("No upcoming care tasks! 🎉\nYour plants are happy."),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming Tasks', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length > 3 ? 3 : tasks.length, // Show up to 3 tasks
          itemBuilder: (context, index) {
            final task = tasks[index];
            final plant = task['plant'];
            final date = task['date'] as DateTime;
            final isOverdue = task['isOverdue'] as bool;

            return Card(
              color: isOverdue ? Colors.red.shade50 : null,
              child: ListTile(
                leading: Icon(
                  task['type'] == 'Water'
                      ? Icons.water_drop
                      : task['type'] == 'Mist'
                      ? Icons.cloud
                      : Icons.eco,
                  color: task['type'] == 'Water'
                      ? Colors.blue
                      : task['type'] == 'Mist'
                      ? Colors.lightBlue
                      : Colors.green,
                ),
                title: Text('${task['type']} ${plant.name}'),
                subtitle: Text(
                  isOverdue
                      ? 'Overdue!'
                      : 'Due: ${DateFormat.yMMMd().add_jm().format(date)}',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : null,
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () {
                    Provider.of<PlantProvider>(
                      context,
                      listen: false,
                    ).markCareDone(plant, task['type']);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantDetailScreen(plantId: plant.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMyPlants(BuildContext context, PlantProvider provider) {
    final plants = provider.plants;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Plants',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantListScreen()),
              ),
              child: const Text('See All'),
            ),
          ],
        ),
        if (plants.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("You haven't added any plants yet."),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantDetailScreen(plantId: plant.id),
                    ),
                  ),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(
                            Icons.local_florist,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(plant.name, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
