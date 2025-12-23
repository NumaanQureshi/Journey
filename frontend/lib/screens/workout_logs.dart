import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/workout_service.dart';

class WorkoutLogs extends StatefulWidget {
  const WorkoutLogs({super.key});

  @override
  State<WorkoutLogs> createState() => _WorkoutLogsState();
}

class _WorkoutLogsState extends State<WorkoutLogs> {
  late Future<List<WorkoutSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _loadSessions();
  }

  Future<List<WorkoutSession>> _loadSessions() async {
    try {
      final sessions = await WorkoutService.getWorkoutSessions();
      debugPrint('DEBUG: Total sessions fetched: ${sessions.length}');
      
      // Filter to only past 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      debugPrint('DEBUG: Now: $now');
      debugPrint('DEBUG: Seven days ago: $sevenDaysAgo');
      
      final filteredSessions = sessions.where((s) {
        final startTime = s.startTime;
        debugPrint('DEBUG: Session ${s.id}: startTime=$startTime, status=${s.status}');
        
        if (startTime == null) {
          debugPrint('DEBUG: Session ${s.id} filtered out - null startTime');
          return false;
        }
        
        final isAfterLimit = startTime.isAfter(sevenDaysAgo);
        final isBeforeNow = startTime.isBefore(now.add(const Duration(hours: 1))); // Allow 1 hour buffer for timezone differences
        
        debugPrint('DEBUG: Session ${s.id}: isAfterLimit=$isAfterLimit, isBeforeNow=$isBeforeNow');
        
        return isAfterLimit && isBeforeNow;
      }).toList();
      
      debugPrint('DEBUG: Filtered sessions: ${filteredSessions.length}');
      
      // Sort by start time (newest first)
      filteredSessions.sort((a, b) => (b.startTime ?? DateTime(2000)).compareTo(a.startTime ?? DateTime(2000)));
      
      return filteredSessions;
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkoutSession>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          final error = snapshot.error.toString();
          debugPrint('ERROR in workout logs: $error');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Unable to load workout history',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sessionsFuture = _loadSessions();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final sessions = snapshot.data ?? [];
        
        if (sessions.isEmpty) {
          return Center(
            child: Text(
              'No workouts in the past 7 days',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            return _LogCard(session: sessions[index]);
          },
        );
      },
    );
  }
}

class _LogCard extends StatelessWidget {
  final WorkoutSession session;

  const _LogCard({required this.session});

  String _formatDuration(int? durationMin) {
    if (durationMin == null) return 'In Progress';
    final minutes = durationMin;
    return '${minutes}m';
  }

  String _getWorkoutName() {
    // For now, just show a generic name
    // In the future, this could be enhanced to fetch and cache template names
    return 'Workout Session';
  }

  @override
  Widget build(BuildContext context) {
    // Convert UTC time from database to local timezone
    final localStartTime = WorkoutService.convertToLocalTime(session.startTime) ?? DateTime.now();
    final isCompleted = session.status == 'completed';
    
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
                  DateFormat('E').format(localStartTime).toUpperCase(),
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  DateFormat('dd').format(localStartTime),
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
                  Text(
                    _getWorkoutName(),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${_formatDuration(session.durationMin)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (session.totalVolumeLb != null && session.totalVolumeLb! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Total Volume: ${session.totalVolumeLb}lbs',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  if (session.caloriesBurned != null && session.caloriesBurned! > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Calories: ${session.caloriesBurned}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isCompleted ? 'Complete' : 'In Progress',
                style: TextStyle(
                  color: isCompleted ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}