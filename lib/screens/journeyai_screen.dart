import 'package:flutter/material.dart';

class JourneyAi extends StatefulWidget {
  const JourneyAi({super.key});

  @override
  State<JourneyAi> createState() => _JourneyAiState();
}

class _JourneyAiState extends State<JourneyAi> {
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
