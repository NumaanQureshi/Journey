import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Workout'),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(
          'Workout',
          style: GoogleFonts.lexend(
            color: const Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
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
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/workout_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.grey,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.black,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(
                Icons.bookmark_border, 
                color: Colors.amber,
              ),
              selectedIcon: Icon(
                Icons.bookmark, 
                color: Colors.amber,
              ), 
              label: 'Plans'
            ),
            NavigationDestination(
              icon: Icon(
                Icons.fitness_center,
                color: Colors.red,
                size: 36,
              ),
              label: '',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.calendar_month,
                color: Colors.blue
              ),
              icon: Icon(
                Icons.calendar_today,
                color: Colors.blue
              ),
              label: 'Logs',
            ),
          ],
        ),
      ),
    );
  }
}