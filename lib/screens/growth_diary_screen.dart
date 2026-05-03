import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/plant.dart';
import '../models/growth_record.dart';
import '../providers/plant_provider.dart';

class GrowthDiaryScreen extends StatefulWidget {
  final Plant plant;

  const GrowthDiaryScreen({super.key, required this.plant});

  @override
  State<GrowthDiaryScreen> createState() => _GrowthDiaryScreenState();
}

class _GrowthDiaryScreenState extends State<GrowthDiaryScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addEntry() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final noteController = TextEditingController();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Growth Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'e.g., First new leaf, repotted, etc.',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final record = GrowthRecord(
                id: const Uuid().v4(),
                plantId: widget.plant.id,
                imagePath: image.path,
                date: DateTime.now(),
                note: noteController.text.trim(),
              );
              Provider.of<PlantProvider>(context, listen: false)
                  .addGrowthRecord(record);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.plant.name} - Growth Diary'),
      ),
      body: Consumer<PlantProvider>(
        builder: (context, provider, child) {
          final records = provider.getGrowthRecords(widget.plant.id);

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No growth records yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text('Take your first photo to track progress!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildTimelineEntry(record, index == 0, index == records.length - 1);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        label: const Text('Add Progress'),
        icon: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildTimelineEntry(GrowthRecord record, bool isFirst, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 2,
                height: 20,
                color: isFirst ? Colors.transparent : Colors.green[200],
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green[100]!, width: 4),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.green[200],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Card content
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(
                      File(record.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy').format(record.date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        if (record.note != null && record.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            record.note!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
