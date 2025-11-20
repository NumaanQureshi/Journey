import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'side_menu.dart';

// --- Challenge Model ---
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
        // TODO: Send completion status to backend
      } else {
        // TODO: Optionally update progress in backend
      }
    }
  }
}

// --- Sample Data ---
// Todo: Static but will add more capped 5 daily challenges per day
final List<Challenge> allDailyChallenges = [
  Challenge(type: 'Daily', title: 'Push-Up Power', description: 'Complete 30 push-ups.', goal: 30, icon: Icons.fitness_center, color: const Color(0xFFBF6A02)),
  Challenge(type: 'Daily', title: 'Cardio Blitz', description: 'Spend 20 minutes on cardio.', goal: 20, icon: Icons.directions_run, color: const Color(0xFF1E88E5)),
  Challenge(type: 'Daily', title: 'Try Something New', description: 'Log a new exercise.', goal: 1, icon: Icons.lightbulb_outline, color: const Color(0xFF667DB5)),
  Challenge(type: 'Daily', title: 'Stretch it Out', description: 'Stretch 10 mins.', goal: 10, icon: Icons.accessibility, color: const Color(0xFFF57C00)),
  Challenge(type: 'Daily', title: 'Squat Session', description: 'Complete 20 squats.', goal: 20, icon: Icons.accessibility_new, color: const Color(0xFF0288D1)),
];

// Todo: Static but will add more capped 3 weekly challenges per week
final List<Challenge> allWeeklyChallenges = [
  Challenge(type: 'Weekly', title: 'New PR', description: 'Hit a personal record.', goal: 1, icon: Icons.trending_up, color: const Color(0xFF43A047)),
  Challenge(type: 'Weekly', title: 'Lower Body Focus', description: 'Log a lower body session.', goal: 1, icon: Icons.accessibility_new, color: const Color(0xFFD81B60)),
  Challenge(type: 'Weekly', title: '3-Workout Week', description: 'Complete 3 workouts.', goal: 3, icon: Icons.calendar_today, color: const Color(0xFF00ACC1)),
  Challenge(type: 'Weekly', title: 'Cardio King/Queen', description: 'Do at least 60 minutes of cardio.', goal: 60, icon: Icons.directions_run, color: const Color(0xFFFF7043)),
  Challenge(type: 'Weekly', title: 'Strength Builder', description: 'Complete 4 strength training sessions.', goal: 4, icon: Icons.fitness_center, color: const Color(0xFF8E24AA)),
];

// Static but will add more for All-Time Achievements 
final List<Challenge> allTimeChallenges = [
  Challenge(type: 'All-Time', title: 'Centurion', description: 'Log 100 total workouts.', goal: 100, icon: Icons.military_tech, color: const Color(0xFABBAC11)),
  Challenge(type: 'All-Time', title: 'Heavy Lifter', description: 'Lift a total of 1000 lbs.', goal: 1000, icon: Icons.scale, color: const Color(0xFF5E35B1)),
  Challenge(type: 'All-Time', title: 'App Explorer', description: 'Try at least 3 sets of every exercise we have listed.', goal: 1, icon: Icons.explore, color: const Color(0xFF43A047)),
  Challenge(type:'All-Time', title: 'First Time', description: 'Login for the first time.', goal: 1, icon: Icons.explore, color: const Color(0xFF43A047)),
  Challenge(type: 'All-Time', title: 'Journey Master', description: 'Complete all achievements.', goal: 4, icon: Icons.emoji_events, color: const Color(0xFFFFD700)),
];

// --- Countdown Widget ---
class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final String label;
  final VoidCallback? onReset;

  const CountdownTimer({super.key, required this.targetTime, required this.label, this.onReset});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration remaining;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    remaining = widget.targetTime.difference(DateTime.now());
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        remaining = widget.targetTime.difference(DateTime.now());
        if (remaining.isNegative) {
          timer.cancel();
          if (widget.onReset != null) widget.onReset!();
          // TODO: Trigger daily/weekly challenge reset via backend
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${d.inDays}d $hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.label}: ${formatDuration(remaining)}',
      style: GoogleFonts.kanit(color: const Color(0xFFFBBF18), fontSize: 14),
    );
  }
}

// --- Challenge Card Widget ---
class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;

  const ChallengeCard({super.key, required this.challenge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: challenge.color.withOpacity(0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Icon(challenge.icon, color: Colors.white, size: 32),
                    if (challenge.completed)
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  challenge.title,
                  style: GoogleFonts.mavenPro(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: challenge.progressPercentage,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.completed ? Colors.greenAccent : Colors.white),
                  minHeight: 6,
                ),
                const SizedBox(height: 4),
                Text(
                  '${challenge.progress.toInt()}/${challenge.goal.toInt()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Main Challenges Screen ---
class Challenges extends StatefulWidget {
  const Challenges({super.key});

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  late List<Challenge> dailyChallenges;
  late List<Challenge> weeklyChallenges;

  @override
  void initState() {
    super.initState();
    _shuffleDailyChallenges();
    _shuffleWeeklyChallenges();
  }

  void _shuffleDailyChallenges() {
    dailyChallenges = List.from(allDailyChallenges);
    // Limit to 5 daily challenges for the day
    if (dailyChallenges.length > 5) {
      dailyChallenges = dailyChallenges.sublist(0, 5);
    }
    // TODO: Fetch daily challenges from backend for user if needed
  }

  void _shuffleWeeklyChallenges() {
    weeklyChallenges = List.from(allWeeklyChallenges);
    // Limit to 3 weekly challenges for the week
    if (weeklyChallenges.length > 3) {
      weeklyChallenges = weeklyChallenges.sublist(0, 3);
    }
    // TODO: Fetch weekly challenges from backend for user if needed
  }

  void _resetDailyChallenges() {
    setState(() {
      _shuffleDailyChallenges();
    });
    // TODO: Notify backend daily reset happened
  }

  void _resetWeeklyChallenges() {
    setState(() {
      _shuffleWeeklyChallenges();
      for (var c in weeklyChallenges) {
        c.progress = 0;
        c.completed = false;
      }
    });
    // TODO: Notify backend weekly reset happened
  }

  // Count completed challenges
  int _completedCount(List<Challenge> challenges) =>
      challenges.where((c) => c.completed).length;

  Widget _buildSection(String title, List<Challenge> challenges,
      {Widget? timer, int cap = 5}) {
    final completed = _completedCount(challenges);
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
        const SizedBox(height: 4),
        // Visual tracker for completed challenges
        Text(
          'Completed: $completed/$cap',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: challenges
              .map(
                (c) => ChallengeCard(
                  challenge: c,
                  onTap: () {
                    setState(() {
                      // TODO: Remove click-to-increment logic later; currently for testing
                      c.updateProgress(1); // Increment by 1 for testing
                    });
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
    final now = DateTime.now();
    final nextDailyReset = DateTime(now.year, now.month, now.day + 1);
    final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    final nextWeeklyReset = DateTime(now.year, now.month, now.day + daysUntilSunday + 1);

    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Challenges'),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFBBF18)),
        title: Text(
          'Challenges',
          style: GoogleFonts.lexend(color: const Color(0xFFFBBF18)),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF252525),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Daily Challenges',
                dailyChallenges,
                timer: CountdownTimer(
                  targetTime: nextDailyReset,
                  label: 'Resets in',
                  onReset: _resetDailyChallenges,
                ),
                cap: 5,
              ),
              _buildSection(
                'Weekly Challenges',
                weeklyChallenges,
                timer: CountdownTimer(
                  targetTime: nextWeeklyReset,
                  label: 'Resets in',
                  onReset: _resetWeeklyChallenges,
                ),
                cap: 3,
              ),
              _buildSection('All-Time Achievements', allTimeChallenges),
            ],
          ),
        ),
      ),
    );
  }
}
