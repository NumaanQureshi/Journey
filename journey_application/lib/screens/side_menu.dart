import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  void _notImplemented(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF667DB5),
                    child: Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text('Guest', style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 4),
                  Text('youremail@example.com', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('Journey AI'),
              onTap: () => _notImplemented(context),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Workout'),
              onTap: () => _notImplemented(context),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Challenges'),
              onTap: () => _notImplemented(context),
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leaderboard'),
              onTap: () => _notImplemented(context),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => _notImplemented(context),
                icon: const Icon(Icons.settings),
                label: const Text('Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
