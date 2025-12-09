import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Mock data model for a workout log entry
class WorkoutLog {
  final String workoutName;
  final DateTime date;
  final Duration duration;

  WorkoutLog({
    required this.workoutName,
    required this.date,
    required this.duration,
  });
}

class WorkoutLogs extends StatelessWidget {
  const WorkoutLogs({super.key});

  // Generate mock data for the past week
  List<WorkoutLog> get _mockLogs {
    final today = DateTime.now();
    return [
      WorkoutLog(
        workoutName: 'Push Day - Chest & Triceps',
        date: today.subtract(const Duration(days: 1)),
        duration: const Duration(minutes: 75, seconds: 30),
      ),
      WorkoutLog(
        workoutName: 'Pull Day - Back & Biceps',
        date: today.subtract(const Duration(days: 3)),
        duration: const Duration(minutes: 62, seconds: 15),
      ),
      WorkoutLog(
        workoutName: 'Leg Day - Quads & Hamstrings',
        date: today.subtract(const Duration(days: 5)),
        duration: const Duration(minutes: 90, seconds: 0),
      ),
      WorkoutLog(
        workoutName: 'Push Day - Shoulders',
        date: today.subtract(const Duration(days: 6)),
        duration: const Duration(minutes: 55, seconds: 45),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _mockLogs.length,
      itemBuilder: (context, index) {
        final log = _mockLogs[index];
        return _LogCard(log: log);
      },
    );
  }
}

class _LogCard extends StatelessWidget {
  final WorkoutLog log;

  const _LogCard({required this.log});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Date Column
            Column(
              children: [
                Text(
                  DateFormat('E').format(log.date).toUpperCase(),
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  DateFormat('dd').format(log.date),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Workout Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.workoutName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Session Time: ${_formatDuration(log.duration)}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}