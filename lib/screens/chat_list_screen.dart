import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sell_post.dart';
import '../services/db_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellBox = Hive.box<SellPost>(DbService.sellBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Conversations'),
      ),
      body: ValueListenableBuilder(
        valueListenable: sellBox.listenable(),
        builder: (context, Box<SellPost> box, _) {
          final posts = box.values.toList();
          
          if (posts.isEmpty) {
            return _buildEmptyState();
          }

          // In a real app, you'd filter for posts you have messages in.
          // For this version, we'll show all marketplace items as potential chats.
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(post.sellerName[0].toUpperCase()),
                ),
                title: Text(post.sellerName),
                subtitle: Text('Re: ${post.plantName}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(post: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No active conversations.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Visit the Marketplace to start chatting with other plant owners!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
