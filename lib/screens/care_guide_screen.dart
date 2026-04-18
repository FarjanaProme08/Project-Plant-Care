import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CareGuideScreen extends StatefulWidget {
  const CareGuideScreen({super.key});

  @override
  State<CareGuideScreen> createState() => _CareGuideScreenState();
}

class _CareGuideScreenState extends State<CareGuideScreen> {
  List<dynamic> _guides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/care_guide.json',
      );
      final data = await json.decode(response);
      setState(() {
        _guides = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Care Guide')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guides.isEmpty
          ? const Center(child: Text('Failed to load guides.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _guides.length,
              itemBuilder: (context, index) {
                final guide = _guides[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide['species'],
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.rule,
                          "Instructions",
                          guide['instructions'],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.wb_sunny,
                          "Sunlight",
                          guide['sunlightRequirements'],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.warning,
                          "Toxicity",
                          guide['toxicityWarnings'],
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
