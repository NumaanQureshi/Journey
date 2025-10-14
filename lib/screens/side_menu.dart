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
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          SizedBox.expand(
              child: Image.asset(
                'assets/images/drawer_bg.png',
                fit: BoxFit.cover,
                ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrawerHeader(
                  // decoration: BoxDecoration(
                  //   color: Colors.black
                  // ),
                  child: Center(
                    child: Column(
                      children: const [
                        SizedBox(height: 12),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF667DB5),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.white
                          ),
                        ),
                        SizedBox(height: 16),
                        Text('Your Name', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  )
                ),
                ListTile(
                  leading: const Icon(
                    Icons.smart_toy,
                    color: Colors.blue),
                  title: const Text(
                    'Journey AI',
                    style: TextStyle(
                      color: Colors.white,
                    )
                  ),
                  tileColor: Colors.transparent,
                  selectedTileColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () => _notImplemented(context),
                ),
                ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.red),
                  title: const Text(
                    'Workout',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  tileColor: Colors.transparent,
                  selectedTileColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () => _notImplemented(context),
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.amber),
                  title: const Text(
                    'Challenges',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  tileColor: Colors.transparent,
                  selectedTileColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () => _notImplemented(context),
                ),
                ListTile(
                  leading: const Icon(Icons.leaderboard, color: Colors.green),
                  title: const Text(
                    'Leaderboard',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  tileColor: Colors.transparent,
                  selectedTileColor: Colors.transparent,
                  hoverColor: Colors.transparent,
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
        ]
      ),
    );
  }
}
