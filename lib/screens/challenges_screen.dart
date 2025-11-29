import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'side_menu.dart';

// Challenge Model
class Challenge {
  final String type; // 'Daily', 'Weekly', 'All-Time'
  final String title;
  final String description;
  double progress;
  final double goal;
  final IconData icon;
  final Color color;
  bool completed;

  Challenge({
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

  void updateProgress(double value) {
    if (!completed) {
      progress += value;
      if (progress >= goal) {
        progress = goal;
        completed = true;
        // TODO: Send backend event: user completed this challenge
      }
    }
  }
}

// Challenge Lists
final List<Challenge> allDailyChallenges = [
  Challenge(type: 'Daily', title: 'Push-Up Power', description: 'Complete 30 push-ups.', goal: 30, icon: Icons.fitness_center, color: const Color(0xFFBF6A02)),
  Challenge(type: 'Daily', title: 'Cardio Blitz', description: 'Spend 20 minutes on cardio.', goal: 20, icon: Icons.directions_run, color: const Color(0xFF1E88E5)),
  Challenge(type: 'Daily', title: 'Try Something New', description: 'Log a new exercise.', goal: 1, icon: Icons.lightbulb_outline, color: const Color(0xFF667DB5)),
  Challenge(type: 'Daily', title: 'Stretch it Out', description: 'Stretch 10 mins.', goal: 10, icon: Icons.accessibility, color: const Color(0xFFF57C00)),
  Challenge(type: 'Daily', title: 'Squat Session', description: 'Complete 20 squats.', goal: 20, icon: Icons.accessibility_new, color: const Color(0xFF0288D1)),
  Challenge(type: 'Daily', title: 'Plank Hold', description: 'Hold plank for 90 seconds.', goal: 90, icon: Icons.sports_gymnastics, color: const Color(0xFF8bc34a)),
  Challenge(type: 'Daily', title: 'Jumping Jack Jolt', description: 'Do 50 jumping jacks.', goal: 50, icon: Icons.directions_run, color: const Color(0xFFE91E63)),
  Challenge(type: 'Daily', title: 'Wall Sit Warrior', description: 'Hold a wall sit for 60 seconds.', goal: 60, icon: Icons.accessibility_new, color: const Color(0xFF9C27B0)),
  Challenge(type: 'Daily', title: 'Bicep Curl Boost', description: 'Do 20 bicep curls.', goal: 20, icon: Icons.fitness_center, color: const Color(0xFFFF9800)),
  Challenge(type: 'Daily', title: 'Lunge Challenge', description: 'Complete 20 lunges.', goal: 20, icon: Icons.accessibility, color: const Color(0xFF00BCD4)),
  Challenge(type: 'Daily', title: 'High Knee Hustle', description: 'Do 40 high knees.', goal: 40, icon: Icons.directions_run, color: const Color(0xFF673AB7)),
  Challenge(type: 'Daily', title: 'Mountain Climber Mayhem', description: 'Do 30 mountain climbers.', goal: 30, icon: Icons.sports_martial_arts, color: const Color(0xFF795548)),
  Challenge(type: 'Daily', title: 'Sit-Up Surge', description: 'Complete 25 sit-ups.', goal: 25, icon: Icons.accessibility_new, color: const Color(0xFFFF5722)),
  Challenge(type: 'Daily', title: 'Burpee Blast', description: 'Do 15 burpees.', goal: 15, icon: Icons.fitness_center, color: const Color(0xFF607D8B)),
  Challenge(type: 'Daily', title: 'Arm Raise Rampage', description: 'Do 30 arm raises.', goal: 30, icon: Icons.accessibility_new, color: const Color(0xFF009688)),
];

final List<Challenge> allWeeklyChallenges = [
  Challenge(type: 'Weekly', title: 'New PR', description: 'Hit a personal record.', goal: 1, icon: Icons.trending_up, color: const Color(0xFF43A047)),
  Challenge(type: 'Weekly', title: 'Lower Body Focus', description: 'Log a lower body session.', goal: 1, icon: Icons.accessibility_new, color: const Color(0xFFD81B60)),
  Challenge(type: 'Weekly', title: '3-Workout Week', description: 'Complete 3 workouts.', goal: 3, icon: Icons.calendar_today, color: const Color(0xFF00ACC1)),
  Challenge(type: 'Weekly', title: 'Cardio King/Queen', description: 'Do at least 60 minutes of cardio.', goal: 60, icon: Icons.directions_run, color: const Color(0xFFFF7043)),
  Challenge(type: 'Weekly', title: 'Strength Builder', description: 'Complete 4 strength training sessions.', goal: 4, icon: Icons.fitness_center, color: const Color(0xFF8E24AA)),
  Challenge(type: 'Weekly', title: 'Total Volume', description: 'Lift 1000 lbs combined volume.', goal: 1000, icon: Icons.scale, color: const Color(0xFF795548)),
  Challenge(type: 'Weekly', title: 'Flexibility Focus', description: 'Stretch 30 minutes total.', goal: 30, icon: Icons.accessibility, color: const Color(0xFFFF9800)),
  Challenge(type: 'Weekly', title: 'Endurance Extra', description: 'Run 10 km total.', goal: 10, icon: Icons.directions_run, color: const Color(0xFF1E88E5)),
  Challenge(type: 'Weekly', title: 'Core Strength', description: 'Complete 3 core workouts.', goal: 3, icon: Icons.sports_gymnastics, color: const Color(0xFF8BC34A)),
  Challenge(type: 'Weekly', title: 'Balance Booster', description: 'Do 20 balance exercises.', goal: 20, icon: Icons.accessibility_new, color: const Color(0xFFE91E63)),
  Challenge(type: 'Weekly', title: 'Upper Body Power', description: 'Do 4 upper body workouts.', goal: 4, icon: Icons.fitness_center, color: const Color(0xFF9C27B0)),
  Challenge(type: 'Weekly', title: 'Speed Challenge', description: 'Complete 5 sprints.', goal: 5, icon: Icons.directions_run, color: const Color(0xFFFF5722)),
  Challenge(type: 'Weekly', title: 'Stamina Builder', description: 'Exercise 120 mins this week.', goal: 120, icon: Icons.fitness_center, color: const Color(0xFF607D8B)),
  Challenge(type: 'Weekly', title: 'HIIT Hero', description: 'Complete 2 HIIT workouts.', goal: 2, icon: Icons.sports_martial_arts, color: const Color(0xFF009688)),
  Challenge(type: 'Weekly', title: 'Mind & Body', description: 'Complete 2 yoga sessions.', goal: 2, icon: Icons.self_improvement, color: const Color(0xFF795548)),
];

final List<Challenge> allTimeChallenges = [
  Challenge(type: 'All-Time', title: 'Centurion', description: 'Log 100 total workouts.', goal: 100, icon: Icons.military_tech, color: const Color(0xFABBAC11)),
  Challenge(type: 'All-Time', title: 'Heavy Lifter', description: 'Lift a total of 1000 lbs.', goal: 1000, icon: Icons.scale, color: const Color(0xFF5E35B1)),
  Challenge(type: 'All-Time', title: 'App Explorer', description: 'Try at least 3 sets of every exercise we have listed.', goal: 1, icon: Icons.explore, color: const Color(0xFF43A047)),
  Challenge(type:'All-Time', title: 'First Time', description: 'Login for the first time.', goal: 1, icon: Icons.explore, color: const Color(0xFF43A047)),
  Challenge(type: 'All-Time', title: 'Journey Master', description: 'Complete all achievements.', goal: 4, icon: Icons.emoji_events, color: const Color(0xFFFFD700)),
];

// Challenge Manager
class ChallengeManager {
  static List<Challenge> dailyChallenges = [];
  static List<Challenge> weeklyChallenges = [];

  static DateTime _nextDailyReset = getNextDailyReset();
  static DateTime _nextWeeklyReset = getNextWeeklyReset();

  static Challenge _copy(Challenge c) {
    return Challenge(
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

  static void maybeResetDaily() {
    if (DateTime.now().isAfter(_nextDailyReset)) {
      dailyChallenges = _cycle(allDailyChallenges, 5);
      _nextDailyReset = getNextDailyReset();
    } else if (dailyChallenges.isEmpty) {
      dailyChallenges = _cycle(allDailyChallenges, 5);
    }
  }

  static void maybeResetWeekly() {
    if (DateTime.now().isAfter(_nextWeeklyReset)) {
      weeklyChallenges = _cycle(allWeeklyChallenges, 3);
      _nextWeeklyReset = getNextWeeklyReset();
    } else if (weeklyChallenges.isEmpty) {
      weeklyChallenges = _cycle(allWeeklyChallenges, 3);
    }
  }

  static DateTime getNextDailyReset() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  static DateTime getNextWeeklyReset() {
    final now = DateTime.now();
    final daysUntilSunday = (7 - now.weekday) % 7;
    final nextSunday = now.add(Duration(days: daysUntilSunday));
    return DateTime(nextSunday.year, nextSunday.month, nextSunday.day); // Sunday midnight
  }

  static void updateJourneyMaster() {
    final jm = allTimeChallenges.firstWhere((x) => x.title == "Journey Master");
    final count = allTimeChallenges.where((x) => x.title != "Journey Master" && x.completed).length;
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
    return Text("${widget.label}: ${fmt(remaining)}",
        style: GoogleFonts.kanit(color: const Color(0xFFFBBF18), fontSize: 14));
  }
}

// Challenge Card
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
        width: 140,
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Icon(challenge.icon, color: Colors.white, size: 28),
                    if (challenge.completed)
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(challenge.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mavenPro(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(challenge.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: challenge.progressPercentage,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.completed ? Colors.greenAccent : Colors.white),
                  minHeight: 5,
                ),
                const SizedBox(height: 2),
                Text("${challenge.progress.toInt()}/${challenge.goal.toInt()}",
                    style: const TextStyle(color: Colors.white70, fontSize: 10)),
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

  @override
  void initState() {
    super.initState();
    ChallengeManager.maybeResetDaily();
    ChallengeManager.maybeResetWeekly();
    dailyReset = ChallengeManager._nextDailyReset;
    weeklyReset = ChallengeManager._nextWeeklyReset;
  }

  int _completedCount(List<Challenge> list) =>
      list.where((c) => c.completed).length;

  Widget _section(String title, List<Challenge> list,
      {Widget? timer, required int cap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: GoogleFonts.kanit(
                    color: const Color(0xFFFBBF18),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            if (timer != null) timer,
          ],
        ),
        Text("Completed: ${_completedCount(list)}/$cap",
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: list
              .map((c) => ChallengeCard(
                    challenge: c,
                    onTap: () {
                      if (c.title != "Journey Master") {
                        // TODO: Remove manual increment; progress should be auto-collected
                        c.updateProgress(1);
                        ChallengeManager.updateJourneyMaster();
                        setState(() {});
                      }
                    },
                  ))
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
        title: Text("Challenges",
            style: GoogleFonts.lexend(color: const Color(0xFFFBBF18))),
      ),
      backgroundColor: const Color(0xFF252525),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section(
              "Daily Challenges",
              ChallengeManager.dailyChallenges,
              timer: CountdownTimer(
                getTarget: () => ChallengeManager.getNextDailyReset(),
                label: "Resets in",
                onExpire: () {
                  ChallengeManager.maybeResetDaily();
                  setState(() {});
                },
              ),
              cap: 5,
            ),
            _section(
              "Weekly Challenges",
              ChallengeManager.weeklyChallenges,
              timer: CountdownTimer(
                getTarget: () => ChallengeManager.getNextWeeklyReset(),
                label: "Resets in",
                onExpire: () {
                  ChallengeManager.maybeResetWeekly();
                  setState(() {});
                },
              ),
              cap: 3,
            ),
            _section("All-Time Achievements", allTimeChallenges,
                cap: allTimeChallenges.length),
          ],
        ),
      ),
    );
  }
}


