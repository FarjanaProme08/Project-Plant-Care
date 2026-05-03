import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/plant.dart';
import '../models/care_history.dart';
import '../models/growth_record.dart';
import '../services/db_service.dart';
import '../services/notification_service.dart';
import '../services/care_scheduler.dart';

class PlantProvider with ChangeNotifier {
  final DbService _dbService;
  final CareScheduler _careScheduler;

  List<Plant> _plants = [];
  
  List<Plant> get plants => _plants;

  PlantProvider(this._dbService, NotificationService notificationService)
    : _careScheduler = CareScheduler(notificationService) {
    _loadPlants();
  }

  void _loadPlants() {
    _plants = _dbService.getAllPlants();
    notifyListeners();
  }

  Future<void> addPlant(Plant plant) async {
    await _dbService.addPlant(plant);
    await _careScheduler.scheduleAllCareForPlant(plant);
    _loadPlants();
  }

  Future<void> updatePlant(Plant plant) async {
    await _dbService.updatePlant(plant);
    await _careScheduler.scheduleAllCareForPlant(plant);
    _loadPlants();
  }

  Future<void> deletePlant(String id) async {
    await _careScheduler.cancelAllCareForPlant(id);
    await _dbService.deletePlant(id);
    _loadPlants();
  }

  Plant? getPlantById(String id) {
    return _dbService.getPlantById(id);
  }

  List<CareHistory> getHistory(String plantId) {
    return _dbService.getHistoryForPlant(plantId);
  }

  // Growth Diary
  List<GrowthRecord> getGrowthRecords(String plantId) {
    return _dbService.getGrowthRecordsForPlant(plantId);
  }

  Future<void> addGrowthRecord(GrowthRecord record) async {
    await _dbService.addGrowthRecord(record);
    notifyListeners();
  }

  Future<void> markCareDone(Plant plant, String careType) async {
    final now = DateTime.now();

    // 1. Record history
    final history = CareHistory(
      id: const Uuid().v4(),
      plantId: plant.id,
      careType: careType,
      timestamp: now,
    );
    await _dbService.addCareHistory(history);

    // 2. Update next date
    if (careType == 'Water') {
      plant.nextWaterDate = _careScheduler.calculateNextDate(
        now,
        plant.waterIntervalDays,
      );
    } else if (careType == 'Mist') {
      plant.nextMistDate = _careScheduler.calculateNextDate(
        now,
        plant.mistIntervalDays,
      );
    } else if (careType == 'Fertilizer') {
      plant.nextFertilizerDate = _careScheduler.calculateNextDate(
        now,
        plant.fertilizerIntervalDays,
      );
    }

    // 3. Save and reschedule
    await updatePlant(plant);
  }

  List<Map<String, dynamic>> getUpcomingTasks() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> tasks = [];

    for (var plant in _plants) {
      if (plant.waterIntervalDays > 0) {
        tasks.add({
          'plant': plant,
          'type': 'Water',
          'date': plant.nextWaterDate,
          'isOverdue': plant.nextWaterDate.isBefore(now),
        });
      }
      if (plant.mistIntervalDays > 0 && plant.nextMistDate != null) {
        tasks.add({
          'plant': plant,
          'type': 'Mist',
          'date': plant.nextMistDate!,
          'isOverdue': plant.nextMistDate!.isBefore(now),
        });
      }
      if (plant.fertilizerIntervalDays > 0 &&
          plant.nextFertilizerDate != null) {
        tasks.add({
          'plant': plant,
          'type': 'Fertilizer',
          'date': plant.nextFertilizerDate!,
          'isOverdue': plant.nextFertilizerDate!.isBefore(now),
        });
      }
    }

    tasks.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
    return tasks;
  }
}
