import 'package:hive/hive.dart';

part 'growth_record.g.dart';

@HiveType(typeId: 2)
class GrowthRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String plantId;

  @HiveField(2)
  String imagePath;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? note;

  GrowthRecord({
    required this.id,
    required this.plantId,
    required this.imagePath,
    required this.date,
    this.note,
  });
}
