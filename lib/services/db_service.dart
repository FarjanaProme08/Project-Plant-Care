import 'package:hive_flutter/hive_flutter.dart';
import '../models/plant.dart';
import '../models/care_history.dart';

class DbService {
  static const String plantBoxName = 'plantsBox';
  static const String historyBoxName = 'historyBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PlantAdapter());
    Hive.registerAdapter(CareHistoryAdapter());

    await Hive.openBox<Plant>(plantBoxName);
    await Hive.openBox<CareHistory>(historyBoxName);
  }

  Box<Plant> get plantBox => Hive.box<Plant>(plantBoxName);
  Box<CareHistory> get historyBox => Hive.box<CareHistory>(historyBoxName);

  // Plant CRUD
  Future<void> addPlant(Plant plant) async {
    await plantBox.put(plant.id, plant);
  }

  Future<void> updatePlant(Plant plant) async {
    await plant.save();
  }

  Future<void> deletePlant(String id) async {
    await plantBox.delete(id);
    // Also delete associated history
    final histories = historyBox.values.where((h) => h.plantId == id).toList();
    for (var h in histories) {
      await h.delete();
    }
  }

  List<Plant> getAllPlants() {
    return plantBox.values.toList();
  }

  Plant? getPlantById(String id) {
    return plantBox.get(id);
  }

  // Care History CRUD
  Future<void> addCareHistory(CareHistory history) async {
    await historyBox.put(history.id, history);
  }

  List<CareHistory> getHistoryForPlant(String plantId) {
    return historyBox.values.where((h) => h.plantId == plantId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Descending
  }
}
