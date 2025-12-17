import 'package:flutter/material.dart';

// Challenge Model
class Challenge {
  int? id;
  final String type; // 'Daily', 'Weekly', 'All-Time'
  final String title;
  final String description;
  double progress;
  final double goal;
  final IconData icon;
  final Color color;
  bool completed;

  Challenge({
    this.id,
    required this.type,
    required this.title,
    required this.description,
    this.progress = 0,
    required this.goal,
    required this.icon,
    required this.color,
    this.completed = false,
  });

  double get progressPercentage => (progress / goal).clamp(0.0, 1.0);

  factory Challenge.fromJson(Map<String, dynamic> json) {
    final localMetaData = getLocalChallengeMetadata(
      json['challenge_title'],
      json['challenge_type'],
    );

    return Challenge(
      id: json['id'] as int,
      type: json['challenge_type'] as String,
      title: json['challenge_title'] as String,
      description: localMetaData['description'] as String,
      progress: double.parse(json['current_progress'].toString()),
      goal: double.parse(json['goal'].toString()),
      icon: localMetaData['icon'] as IconData,
      color: localMetaData['color'] as Color,
      completed: json['is_completed'] as bool,
    );
  }
}

// Helper function to get local metadata for a challenge
Map<String, dynamic> getLocalChallengeMetadata(String title, String type) {
  List<Challenge> sourceList;
  if (type == 'Daily') {
    sourceList = allDailyChallenges;
  } else if (type == 'Weekly') {
    sourceList = allWeeklyChallenges;
  } else {
    sourceList = allTimeChallenges;
  }

  try {
    final localChallenge = sourceList.firstWhere((c) => c.title == title);
    return {
      'description': localChallenge.description,
      'icon': localChallenge.icon,
      'color': localChallenge.color,
    };
  } catch (e) {
    // Return default values if no match is found to avoid crashing
    return {
      'description': 'No description found',
      'icon': Icons.help,
      'color': Colors.grey,
      'goal': 1.0, // Add a default goal
    };
  }
}

// Challenge Lists
// (Daily, Weekly, All-Time)

final List<Challenge> allDailyChallenges = [
  Challenge(
    type: 'Daily',
    title: 'Push-Up Power',
    description: 'Complete 30 push-ups.',
    goal: 30,
    icon: Icons.fitness_center,
    color: const Color(0xFFBF6A02),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Cardio Blitz',
    description: 'Spend 20 minutes on cardio.',
    goal: 20,
    icon: Icons.directions_run,
    color: const Color(0xFF1E88E5),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Try Something New',
    description: 'Log a new exercise.',
    goal: 1,
    icon: Icons.lightbulb_outline,
    color: const Color(0xFF667DB5),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Stretch it Out',
    description: 'Stretch 10 mins.',
    goal: 10,
    icon: Icons.accessibility,
    color: const Color(0xFFF57C00),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Squat Session',
    description: 'Complete 20 squats.',
    goal: 20,
    icon: Icons.accessibility_new,
    color: const Color(0xFF0288D1),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Plank Hold',
    description: 'Hold plank for 90 seconds.',
    goal: 90,
    icon: Icons.sports_gymnastics,
    color: const Color(0xFF8bc34a),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Jumping Jack Jolt',
    description: 'Do 50 jumping jacks.',
    goal: 50,
    icon: Icons.directions_run,
    color: const Color(0xFFE91E63),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Wall Sit Warrior',
    description: 'Hold a wall sit for 60 seconds.',
    goal: 60,
    icon: Icons.accessibility_new,
    color: const Color(0xFF9C27B0),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Bicep Curl Boost',
    description: 'Do 20 bicep curls.',
    goal: 20,
    icon: Icons.fitness_center,
    color: const Color(0xFFFF9800),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Lunge Challenge',
    description: 'Complete 20 lunges.',
    goal: 20,
    icon: Icons.accessibility,
    color: const Color(0xFF00BCD4),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'High Knee Hustle',
    description: 'Do 40 high knees.',
    goal: 40,
    icon: Icons.directions_run,
    color: const Color(0xFF673AB7),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Mountain Climber Mayhem',
    description: 'Do 30 mountain climbers.',
    goal: 30,
    icon: Icons.sports_martial_arts,
    color: const Color(0xFF795548),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Sit-Up Surge',
    description: 'Complete 25 sit-ups.',
    goal: 25,
    icon: Icons.accessibility_new,
    color: const Color(0xFFFF5722),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Burpee Blast',
    description: 'Do 15 burpees.',
    goal: 15,
    icon: Icons.fitness_center,
    color: const Color(0xFF607D8B),
    id: null,
  ),
  Challenge(
    type: 'Daily',
    title: 'Arm Raise Rampage',
    description: 'Do 30 arm raises.',
    goal: 30,
    icon: Icons.accessibility_new,
    color: const Color(0xFF009688),
    id: null,
  ),
];

final List<Challenge> allWeeklyChallenges = [
  Challenge(
    type: 'Weekly',
    title: 'New PR',
    description: 'Hit a personal record.',
    goal: 1,
    icon: Icons.trending_up,
    color: const Color(0xFF43A047),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Lower Body Focus',
    description: 'Log a lower body session.',
    goal: 1,
    icon: Icons.accessibility_new,
    color: const Color(0xFFD81B60),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: '3-Workout Week',
    description: 'Complete 3 workouts.',
    goal: 3,
    icon: Icons.calendar_today,
    color: const Color(0xFF00ACC1),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Cardio King/Queen',
    description: 'Do at least 60 minutes of cardio.',
    goal: 60,
    icon: Icons.directions_run,
    color: const Color(0xFFFF7043),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Strength Builder',
    description: 'Complete 4 strength training sessions.',
    goal: 4,
    icon: Icons.fitness_center,
    color: const Color(0xFF8E24AA),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Total Volume',
    description: 'Lift 1000 lbs combined volume.',
    goal: 1000,
    icon: Icons.scale,
    color: const Color(0xFF795548),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Flexibility Focus',
    description: 'Stretch 30 minutes total.',
    goal: 30,
    icon: Icons.accessibility,
    color: const Color(0xFFFF9800),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Endurance Extra',
    description: 'Run 10 km total.',
    goal: 10,
    icon: Icons.directions_run,
    color: const Color(0xFF1E88E5),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Core Strength',
    description: 'Complete 3 core workouts.',
    goal: 3,
    icon: Icons.sports_gymnastics,
    color: const Color(0xFF8BC34A),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Balance Booster',
    description: 'Do 20 balance exercises.',
    goal: 20,
    icon: Icons.accessibility_new,
    color: const Color(0xFFE91E63),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Upper Body Power',
    description: 'Do 4 upper body workouts.',
    goal: 4,
    icon: Icons.fitness_center,
    color: const Color(0xFF9C27B0),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Speed Challenge',
    description: 'Complete 5 sprints.',
    goal: 5,
    icon: Icons.directions_run,
    color: const Color(0xFFFF5722),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Stamina Builder',
    description: 'Exercise 120 mins this week.',
    goal: 120,
    icon: Icons.fitness_center,
    color: const Color(0xFF607D8B),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'HIIT Hero',
    description: 'Complete 2 HIIT workouts.',
    goal: 2,
    icon: Icons.sports_martial_arts,
    color: const Color(0xFF009688),
    id: null,
  ),
  Challenge(
    type: 'Weekly',
    title: 'Mind & Body',
    description: 'Complete 2 yoga sessions.',
    goal: 2,
    icon: Icons.self_improvement,
    color: const Color(0xFF795548),
    id: null,
  ),
];

final List<Challenge> allTimeChallenges = [
  Challenge(
    type: 'All-Time',
    title: 'Centurion',
    description: 'Log 100 total workouts.',
    goal: 100,
    icon: Icons.military_tech,
    color: const Color(0xFABBAC11),
    id: null,
  ),
  Challenge(
    type: 'All-Time',
    title: 'Heavy Lifter',
    description: 'Lift a total of 1000 lbs.',
    goal: 1000,
    icon: Icons.scale,
    color: const Color(0xFF5E35B1),
    id: null,
  ),
  Challenge(
    type: 'All-Time',
    title: 'App Explorer',
    description: 'Try at least 3 sets of every exercise we have listed.',
    goal: 1,
    icon: Icons.explore,
    color: const Color(0xFF43A047),
    id: null,
  ),
  Challenge(
    type: 'All-Time',
    title: 'First Time',
    description: 'Login for the first time.',
    goal: 1,
    icon: Icons.explore,
    color: const Color(0xFF43A047),
    id: null,
  ),
  Challenge(
    type: 'All-Time',
    title: 'Journey Master',
    description: 'Complete all achievements.',
    goal: 4,
    icon: Icons.emoji_events,
    color: const Color(0xFFFFD700),
    id: null,
  ),
];