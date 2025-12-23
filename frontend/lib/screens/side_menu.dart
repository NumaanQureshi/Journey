import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'challenges_screen.dart';
import 'home_screen.dart';
import 'workout_screen.dart';
import 'settings_screen.dart';
import 'user_analytics_screen.dart';
import '../providers/user_provider.dart';

class SideMenu extends StatelessWidget {
  final String? currentScreen;

  const SideMenu({super.key, this.currentScreen});

  void _notImplemented(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 48, 48, 48),
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrawerHeader(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF667DB5),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            final displayName = userProvider.displayName ?? 'User';
                            return Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.blue),
                  title: const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  selected: currentScreen == 'Home',
                  selectedTileColor: Colors.grey.withValues(alpha: 0.3),
                  hoverColor: Colors.transparent,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentScreen != 'Home') {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.red),
                  title: const Text(
                    'Workout',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  selected: currentScreen == 'Workout',
                  selectedTileColor: Colors.grey.withValues(alpha: 0.3),
                  hoverColor: Colors.transparent,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentScreen != 'Workout') {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const Workout()));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.amber),
                  title: const Text(
                    'Challenges',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  selected: currentScreen == 'Challenges',
                  selectedTileColor: Colors.grey.withValues(alpha: 0.3),
                  hoverColor: Colors.transparent,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentScreen != 'Challenges') {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const Challenges()));
                    }
                  },
                ),

                // == CHALLENGE AND LEADERBOARD FUNCTIONALITY COMING SOON ==
                // ListTile(
                //   leading: const Icon(Icons.leaderboard, color: Colors.green),
                //   title: const Text(
                //     'Leaderboard',
                //     style: TextStyle(
                //       color: Colors.white,
                //     ),
                //   ),
                //   tileColor: Colors.transparent,
                //   selectedTileColor: Colors.transparent,
                //   hoverColor: Colors.transparent,
                //   onTap: () => _notImplemented(context),
                // ),
                // ListTile(
                //   leading: const Icon(Icons.analytics, color: Colors.purpleAccent),
                //   title: const Text(
                //     'Analytics',
                //     style: TextStyle(
                //       color: Colors.white,
                //     ),
                //   ),
                //   selected: currentScreen == 'Analytics',
                //   selectedTileColor: Colors.grey.withValues(alpha: 0.3),
                //   hoverColor: Colors.transparent,
                //   onTap: () {
                //     Navigator.pop(context);
                //     if (currentScreen != 'Analytics') {
                //       Navigator.pushReplacement(context,
                //           MaterialPageRoute(builder: (context) => const UserAnalyticsScreen()));
                //     }
                //   },
                // ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey.shade200,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                    },
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
