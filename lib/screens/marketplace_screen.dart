import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sell_post.dart';
import '../services/db_service.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late Box<SellPost> _sellBox;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _sellBox = Hive.box<SellPost>(DbService.sellBoxName);
    _isInit = true;
  }

  void _addPost() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sell Your Plant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plant Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price (\$)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final post = SellPost(
                id: const Uuid().v4(),
                sellerName: auth.currentUserEmail?.split('@')[0] ?? 'Seller',
                plantName: nameController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                datePosted: DateTime.now(),
                sellerEmail: auth.currentUserEmail ?? '',
              );
              _sellBox.put(post.id, post);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Marketplace'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _sellBox.listenable(),
        builder: (context, Box<SellPost> box, _) {
          final posts = box.values.toList()..sort((a, b) => b.datePosted.compareTo(a.datePosted));

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.green[200]),
                  const SizedBox(height: 16),
                  const Text('No plants for sale yet.', style: TextStyle(fontSize: 18)),
                  const Text('Be the first to post!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPost,
        label: const Text('Sell Plant'),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildPostCard(SellPost post) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.green[50],
              child: Center(
                child: Icon(Icons.local_florist, size: 50, color: Colors.green[200]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.plantName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${post.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.sellerName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openChat(post),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 30),
                    ),
                    child: const Text('Chat', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(SellPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(post: post)),
    );
  }
}
