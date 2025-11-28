import 'package:flutter/material.dart';

class JourneyAiScreen extends StatefulWidget {
  const JourneyAiScreen({super.key});

  @override
  State<JourneyAiScreen> createState() => _JourneyAiScreenState();
}

class _JourneyAiScreenState extends State<JourneyAiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Journey AI Screen',
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
    );
  }
}