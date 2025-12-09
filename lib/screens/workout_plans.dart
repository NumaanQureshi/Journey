import 'package:flutter/material.dart';

class WorkoutPlans extends StatefulWidget {
  const WorkoutPlans({super.key});

  @override
  State<WorkoutPlans> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlans> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockSplits = [
      {
        'name': 'Push/Pull/Legs',
        'description': 'Classic 3-day split for strength.'
      },
      {
        'name': 'Upper/Lower Split',
        'description': '4-day split focusing on upper and lower body.'
      },
      {
        'name': 'Full Body Blast',
        'description': '3 times a week, for beginners.'
      },
    ];

    // Mock data for customizable workout days
    final List<String> customizableDays = [
      'Chest Day',
      'Back Day',
      'Leg Day',
      'Shoulder Day',
      'Arm Day'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Weekly Splits
          const Text(
            'Weekly Splits',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockSplits.length,
            itemBuilder: (context, index) {
              final split = mockSplits[index];
              return Card(
                color: const Color(0xFF2C2C2C),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(split['name']!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(split['description']!,
                      style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                    onPressed: () {/* TODO: Implement edit split */},
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Section 2: Customize your Days
          const Text(
            'Customize Your Days',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...customizableDays.map((day) => Card(
                color: const Color(0xFF2C2C2C),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(day,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () {/* TODO: Implement customize day */},
                  ),
                ),
              )),
          ],
        ),
      )
    );
  }
}