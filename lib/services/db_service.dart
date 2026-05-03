import 'package:hive_flutter/hive_flutter.dart';
import '../models/plant.dart';
import '../models/care_history.dart';
import '../models/growth_record.dart';
import '../models/sell_post.dart';
import '../models/chat_message.dart';

class DbService {
  static const String plantBoxName = 'plantsBox';
  static const String historyBoxName = 'historyBox';
  static const String growthBoxName = 'growthBox';
  static const String sellBoxName = 'sellBox';
  static const String chatBoxName = 'chatBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PlantAdapter());
    Hive.registerAdapter(CareHistoryAdapter());
    Hive.registerAdapter(GrowthRecordAdapter());
    Hive.registerAdapter(SellPostAdapter());
    Hive.registerAdapter(ChatMessageAdapter());

    await Hive.openBox<Plant>(plantBoxName);
    await Hive.openBox<CareHistory>(historyBoxName);
    await Hive.openBox<GrowthRecord>(growthBoxName);
    await Hive.openBox<SellPost>(sellBoxName);
    await Hive.openBox<ChatMessage>(chatBoxName);
  }

  Box<Plant> get plantBox => Hive.box<Plant>(plantBoxName);
  Box<CareHistory> get historyBox => Hive.box<CareHistory>(historyBoxName);
  Box<GrowthRecord> get growthBox => Hive.box<GrowthRecord>(growthBoxName);

  // Plant CRUD
  Future<void> addPlant(Plant plant) async {
    await plantBox.put(plant.id, plant);
  }

  Future<void> updatePlant(Plant plant) async {
    await plant.save();
  }

  Future<void> deletePlant(String id) async {
    await plantBox.delete(id);
    // Also delete associated history and growth records
    final histories = historyBox.values.where((h) => h.plantId == id).toList();
    for (var h in histories) {
      await h.delete();
    }
    final records = growthBox.values.where((r) => r.plantId == id).toList();
    for (var r in records) {
      await r.delete();
    }
  }

  List<Plant> getAllPlants() {
    return plantBox.values.toList();
  }

  Plant? getPlantById(String id) {
    return plantBox.get(id);
  }

  // Growth Record CRUD
  Future<void> addGrowthRecord(GrowthRecord record) async {
    await growthBox.put(record.id, record);
  }

  List<GrowthRecord> getGrowthRecordsForPlant(String plantId) {
    return growthBox.values.where((r) => r.plantId == plantId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Descending (newest first)
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
