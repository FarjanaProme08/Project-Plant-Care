import 'package:hive/hive.dart';

part 'plant.g.dart';

@HiveType(typeId: 0)
class Plant extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String species;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  int waterIntervalDays;

  @HiveField(5)
  int mistIntervalDays;

  @HiveField(6)
  int fertilizerIntervalDays;

  @HiveField(7)
  DateTime nextWaterDate;

  @HiveField(8)
  DateTime? nextMistDate;

  @HiveField(9)
  DateTime? nextFertilizerDate;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    this.imagePath,
    required this.waterIntervalDays,
    required this.mistIntervalDays,
    required this.fertilizerIntervalDays,
    required this.nextWaterDate,
    this.nextMistDate,
    this.nextFertilizerDate,
  });
}
