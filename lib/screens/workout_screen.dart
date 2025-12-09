import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'side_menu.dart';
import 'workout_session.dart';
import 'workout_plans.dart';
import 'dart:core';
import 'workout_logs.dart';

class Workout extends StatefulWidget {
  const Workout({super.key});

  @override
  State<Workout> createState() => _WorkoutState();
}

class WorkoutContent extends StatelessWidget {
  const WorkoutContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI Suggestion Card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Card(
            color: const Color(0xFF2C2C2C),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/updated_journey_logo.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "We're not skipping legs today.",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Start Session Button
        Expanded(
          child: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutSession(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 24, 24, 24),
                  shadowColor: Colors.red,
                  surfaceTintColor: const Color.fromARGB(255, 37, 12, 10),
                  elevation: 15,
                  shape: const CircleBorder(),
                  side: const BorderSide(color: Colors.orange, width: 2),
                ),
                child: Text(
                  'Start Session',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mavenPro(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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


  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const WorkoutPlans(),
      const WorkoutContent(),
      const WorkoutLogs(),
    ];
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Workout'),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
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
      body: screens.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        destinations: _workoutNavBarDestinations,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: Color(0xFF2C2C2C),
        indicatorColor: Colors.black,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          // selected labels
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, color: Colors.white);
          }
          // unselected labels
          return const TextStyle(fontSize: 12, color: Colors.grey);
        }),
      ),
    );
  }
}
