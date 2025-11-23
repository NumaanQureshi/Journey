import 'package:flutter/material.dart';
import 'side_menu.dart';
import 'dart:core';

class Workout extends StatefulWidget {
  const Workout({super.key});

  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  int _selectedIndex = 1;

  // TODO: demo logic. add backend logic later
  int _streakLevel = 0; // 0: none, 1: small, 2: medium, 3: high
  final List<Color> _streakColors = [
    Colors.grey.shade700,
    Colors.orangeAccent,
    Colors.orange,
    Colors.red,
  ];

  static const List<Widget> _workoutNavBarDestinations = <Widget>[
    NavigationDestination(
      icon: Icon(Icons.bookmark_border, color: Colors.amber),
      selectedIcon: Icon(Icons.bookmark, color: Colors.amber),
      label: 'Plans',
    ),
    NavigationDestination(
      icon: Icon(Icons.fitness_center, color: Colors.red, size: 36),
      label: '',
    ),
    NavigationDestination(
      selectedIcon: Icon(Icons.calendar_month, color: Colors.blue),
      icon: Icon(Icons.calendar_today, color: Colors.blue),
      label: 'Logs',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Workout'),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              tooltip: 'Workout Streak',
              icon: Icon(
                Icons.local_fire_department,
                color: _streakColors[_streakLevel],
                size: 28,
              ),
              onPressed: () {
                // TODO: demo logic. add backend logic later
                setState(() {
                  _streakLevel = (_streakLevel + 1) % _streakColors.length;
                });
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Workout Screen',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
          destinations: _workoutNavBarDestinations,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Color(0xFF2C2C2C),
          indicatorColor: Colors.black,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((Set<WidgetState> states) {
            // selected labels
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                color: Colors.white,
              );
            }
            // unselected labels
            return const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            );
          }),
        ),
    );
  }
}
