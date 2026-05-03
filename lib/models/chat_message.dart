import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 4)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderEmail;

  @HiveField(2)
  final String receiverEmail;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String postId; // To group messages by the plant being sold

  ChatMessage({
    required this.id,
    required this.senderEmail,
    required this.receiverEmail,
    required this.text,
    required this.timestamp,
    required this.postId,
  });
}
