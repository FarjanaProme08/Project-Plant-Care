import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/sell_post.dart';
import '../models/chat_message.dart';
import '../services/db_service.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final SellPost post;
  const ChatScreen({super.key, required this.post});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box<ChatMessage> _chatBox;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _chatBox = Hive.box<ChatMessage>(DbService.chatBoxName);
    _isInit = true;
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserEmail = auth.currentUserEmail ?? 'anonymous';

    final message = ChatMessage(
      id: const Uuid().v4(),
      senderEmail: currentUserEmail,
      receiverEmail: widget.post.sellerEmail,
      text: text,
      timestamp: DateTime.now(),
      postId: widget.post.id,
    );

    _chatBox.put(message.id, message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final auth = Provider.of<AuthProvider>(context);
    final currentUserEmail = auth.currentUserEmail ?? 'anonymous';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.sellerName, style: const TextStyle(fontSize: 16)),
            Text('Regarding: ${widget.post.plantName}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _chatBox.listenable(),
              builder: (context, Box<ChatMessage> box, _) {
                // Filter messages for THIS specific plant/post
                final messages = box.values
                    .where((m) => m.postId == widget.post.id)
                    .toList()
                  ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet. Start the conversation!'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderEmail == currentUserEmail;
                    return _buildMessageBubble(msg.text, isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
