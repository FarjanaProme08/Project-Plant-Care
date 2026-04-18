import 'package:hive/hive.dart';

part 'care_history.g.dart';

@HiveType(typeId: 1)
class CareHistory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String plantId;

  @HiveField(2)
  String careType; // "Water", "Mist", "Fertilizer"

  @HiveField(3)
  DateTime timestamp;

  CareHistory({
    required this.id,
    required this.plantId,
    required this.careType,
    required this.timestamp,
  });
}
