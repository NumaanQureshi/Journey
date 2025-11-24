import 'package:flutter/material.dart';
import 'screens/login_screen.dart';



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

    );
  }
}