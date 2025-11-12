import 'package:flutter/material.dart';
import 'screens/sign_up.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/workout_screen.dart';




void main() {
  runApp(const JourneyApp());
}

class JourneyApp extends StatelessWidget {
  const JourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey',
      debugShowCheckedModeBanner: false,
      // Start with Login screen
      home: const LoginScreen(),

      // Named routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUp(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/challenges': (context) => const Challenges(),
        '/workout': (context) => const Workout(),
      },
    );
  }
}