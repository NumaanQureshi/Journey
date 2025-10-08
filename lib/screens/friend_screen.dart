import 'package:flutter/material.dart';

class Friend extends StatefulWidget {
  const Friend({super.key});

  @override
  State<Friend> createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  // In-memory placeholder list; replace with DB-backed source later.
  final List<String> _friends = ['Friend 1', 'Friend 2', 'Friend 3'];

  void _addFriend(String name) {
    if (name.isEmpty) return;
    setState(() => _friends.add(name));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added friend: $name')),
    );
  }

  Future<void> _showAddDialog() async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a Friend'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Friend name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );

    if (result == true) {
      _addFriend(controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(
            color: Color(0xFFFBBF18),
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add a Friend'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667DB5)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _friends.isEmpty
                ? const Center(child: Text('No friends yet'))
                : ListView.separated(
                    itemCount: _friends.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final name = _friends[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() => _friends.removeAt(index));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed $name')));
                          },
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Note: Friends are currently stored locally; DB integration coming soon.', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}
