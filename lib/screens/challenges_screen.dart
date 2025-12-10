import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../authentication/api_service.dart';
import '../authentication/authentication.dart';
import 'side_menu.dart';

// Challenge Model
class Challenge {
  final int? id;
  final String type; // 'Daily', 'Weekly', 'All-Time'
  final String title;
  final String description;
  double progress;
  final double goal;
  final IconData icon;
  final Color color;
  bool completed;

  Challenge({
    required this.id,
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
    // You need a way to map the static challenge properties (icon, color)
    // which are not stored in the database.

    // Create a helper function or map to find the local metadata:
    final localMetaData = _getLocalChallengeMetadata(
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
Map<String, dynamic> _getLocalChallengeMetadata(String title, String type) {
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

// Challenge Manager

class ChallengeManager {
  static List<Challenge> dailyChallenges = [];
  static List<Challenge> weeklyChallenges = [];

  static Challenge _copy(Challenge c) {
    return Challenge(
      id: c.id,
      type: c.type,
      title: c.title,
      description: c.description,
      goal: c.goal,
      icon: c.icon,
      color: c.color,
      progress: 0,
      completed: false,
    );
  }

  static List<Challenge> _cycle(List<Challenge> source, int count) {
    source.shuffle();
    return List.generate(count, (i) => _copy(source[i]));
  }

  // Daily reset at midnight
  static void resetDaily() {
    dailyChallenges = _cycle(allDailyChallenges, 5);
  }

  // Weekly reset at Sunday midnight
  static void resetWeekly() {
    weeklyChallenges = _cycle(allWeeklyChallenges, 3);
  }

  static DateTime getNextDailyReset() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  static DateTime getNextWeeklyReset() {
    final now = DateTime.now();
    final daysUntilSunday = (7 - now.weekday) % 7;
    final nextSunday = now.add(Duration(days: daysUntilSunday));
    return DateTime(
      nextSunday.year,
      nextSunday.month,
      nextSunday.day,
    ); // Sunday midnight
  }

  static void updateJourneyMaster() {
    final jm = allTimeChallenges.firstWhere((x) => x.title == "Journey Master");
    final count = allTimeChallenges
        .where((x) => x.title != "Journey Master" && x.completed)
        .length;
    jm.progress = count.toDouble();
    jm.completed = jm.progress >= jm.goal;
  }
}

// Countdown Timer
class CountdownTimer extends StatefulWidget {
  final DateTime Function() getTarget;
  final String label;
  final VoidCallback onExpire;

  const CountdownTimer({
    super.key,
    required this.getTarget,
    required this.label,
    required this.onExpire,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer timer;
  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final target = widget.getTarget();
    setState(() {
      remaining = target.difference(now);
      if (remaining.isNegative) {
        widget.onExpire();
        remaining = widget.getTarget().difference(DateTime.now());
      }
    });
  }

  String fmt(Duration d) {
    if (d.isNegative) return "00:00:00";
    final hh = d.inHours.toString().padLeft(2, "0");
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$hh:$mm:$ss";
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.label}: ${fmt(remaining)}",
      style: GoogleFonts.kanit(color: const Color(0xFFFBBF18), fontSize: 14),
    );
  }
}

// Challenge Card (Compact)

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;

  const ChallengeCard({super.key, required this.challenge, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color cardColor = challenge.color.withAlpha(220);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140, // compact width
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Icon(challenge.icon, color: Colors.white, size: 28),
                    if (challenge.completed)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  challenge.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mavenPro(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: challenge.progressPercentage,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    challenge.completed ? Colors.greenAccent : Colors.white,
                  ),
                  minHeight: 5,
                ),
                const SizedBox(height: 2),
                Text(
                  "${challenge.progress.toInt()}/${challenge.goal.toInt()}",
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Main Challenges Page

class Challenges extends StatefulWidget {
  const Challenges({super.key});

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  late DateTime dailyReset;
  late DateTime weeklyReset;
  
  Widget? _dailyTimer;
  Widget? _weeklyTimer;
  // ignore: unused_field
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  List<Challenge> _dailyChallenges = [];
  List<Challenge> _weeklyChallenges = [];
  List<Challenge> _allTimeChallenges = [];

  @override
  void initState() {
    super.initState();
    // ChallengeManager.resetDaily();
    // ChallengeManager.resetWeekly();
    // Initialize all-time challenges from the global list to avoid empty state on first load
    setState(() {
      _allTimeChallenges = allTimeChallenges;
    });
    dailyReset = ChallengeManager.getNextDailyReset();
    weeklyReset = ChallengeManager.getNextWeeklyReset();

    _dailyTimer = CountdownTimer(
      getTarget: () => dailyReset,
      label: "Resets in",
      onExpire: () => _fetchChallenges(),
    );

    _weeklyTimer = CountdownTimer(
      getTarget: () => weeklyReset,
      label: "Resets in",
      onExpire: () => _fetchChallenges(),
    );

    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse(ApiService.challenges()),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      // Handle error, e.g., show a snackbar
      // debugPrint("Failed to fetch challenges: ${response.body}");
      return;
    }

    final jsonResponse = jsonDecode(response.body);
    final List<dynamic> fetchedDataJson = jsonResponse['challenges'];

    // Map JSON to Challenge objects
    final fetchedData = fetchedDataJson.map((json) {
      // You'll need to define a Challenge.fromJson factory method for clean parsing:
      return Challenge.fromJson(json); // See C. below
    }).toList();

    // 2. Process Response (Parse and separate)
    final newDaily = fetchedData.where((c) => c.type == 'Daily').toList();
    final newWeekly = fetchedData.where((c) => c.type == 'Weekly').toList();

    // Merge All-Time: You'll fetch progress for All-Time from the API,
    // but the definition (title, goal, icon) is local.
    final fetchedAllTime = fetchedData.where((c) => c.type == 'All-Time');

    for (final fetched in fetchedAllTime) {
      final localChallenge = allTimeChallenges.firstWhere(
        (c) => c.title == fetched.title,
        orElse: () => throw Exception("Challenge mismatch"),
      );

      // Update local object with database progress/completion
      localChallenge.progress = fetched.progress;
      localChallenge.completed = fetched.completed;
    }
    ChallengeManager.updateJourneyMaster(); // Update master challenge based on fetched data

    if (mounted) {
      setState(() {
        _dailyChallenges = newDaily;
        _weeklyChallenges = newWeekly;
        _allTimeChallenges = List.from(allTimeChallenges); // Use the updated global list
        _isLoading = false;
        // The reset dates should ideally come from the server to keep them in sync,
        // but for now, we'll keep the local calculation as a fallback.
        dailyReset = ChallengeManager.getNextDailyReset();
        weeklyReset = ChallengeManager.getNextWeeklyReset();
      });
    }
  }

  Future<void> _incrementChallenge(Challenge c) async {
    if (c.id == null) return; // Cannot update if no ID is assigned

    final token = await _authService.getToken();
    final response = await http.put(
      Uri.parse('${ApiService.challenges()}/${c.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'increment': 1, // Send a fixed increment
      }),
    );

    if (response.statusCode == 200) {
      _fetchChallenges(); // Refresh data from server after successful update
    }
  }

  int _completedCount(List<Challenge> list) =>
      list.where((c) => c.completed).length;

  Widget _section(
    String title,
    List<Challenge> list, {
    Widget? timer,
    required int cap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.kanit(
                color: const Color(0xFFFBBF18),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (timer != null) timer,
          ],
        ),
        Text(
          "Completed: ${_completedCount(list)}/$cap",
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: list
              .map(
                (c) => ChallengeCard(
                  challenge: c,
                  onTap: () {
                    // Prevent interaction with the master achievement or completed challenges
                    if (c.title == "Journey Master" || c.completed) {
                      return;
                    }

                    // For any other challenge, send an increment request.
                    _incrementChallenge(c);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Challenges'),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFBBF18)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Challenges",
          style: GoogleFonts.lexend(color: const Color(0xFFFBBF18)),
        ),
      ),
      backgroundColor: const Color(0xFF252525),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section(
              "Daily Challenges",
              _dailyChallenges, // Use the fetched list
              timer: _dailyTimer,
              cap: 5,
            ),
            _section(
              "Weekly Challenges",
              _weeklyChallenges, // Use the fetched list
              timer: _weeklyTimer,
              cap: 3,
            ),
            _section(
              "All-Time Achievements",
              _allTimeChallenges, // Use the state variable
              cap: _allTimeChallenges.length,
            ),
          ],
        ),
      ),
    );
  }
}
