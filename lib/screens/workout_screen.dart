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