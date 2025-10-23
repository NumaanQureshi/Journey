import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Friend extends StatefulWidget {
  const Friend({super.key});

  @override
  State<Friend> createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  // TODO: replace with DB friends later.
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
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(
          'Friends',
          style: GoogleFonts.lexend(
            color: const Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/profile_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your friends',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    ElevatedButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add a Friend'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667DB5),
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white30),
              Expanded(
                child: _friends.isEmpty
                    ? const Center(
                        child:
                            Text('No friends yet', style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final name = _friends[index];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading:
                                  const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(name,
                                  style: const TextStyle(color: Colors.black87)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  setState(() => _friends.removeAt(index));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Removed $name')));
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Note: Friends are currently stored locally; DB integration coming soon.', style: TextStyle(color: Colors.grey[400])),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
