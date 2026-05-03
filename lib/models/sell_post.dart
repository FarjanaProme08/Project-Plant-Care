import 'package:hive/hive.dart';

part 'sell_post.g.dart';

@HiveType(typeId: 3)
class SellPost extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sellerName;

  @HiveField(2)
  String plantName;

  @HiveField(3)
  String description;

  @HiveField(4)
  double price;

  @HiveField(5)
  String? imagePath;

  @HiveField(6)
  DateTime datePosted;

  @HiveField(7)
  String sellerEmail;

  SellPost({
    required this.id,
    required this.sellerName,
    required this.plantName,
    required this.description,
    required this.price,
    this.imagePath,
    required this.datePosted,
    required this.sellerEmail,
  });
}
