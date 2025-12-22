import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/challenge_provider.dart';
import '../services/challenge_service.dart';
import 'side_menu.dart';

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
  bool _isLoading = true;  List<Challenge> _dailyChallenges = [];
  List<Challenge> _weeklyChallenges = [];
  List<Challenge> _allTimeChallenges = [];

  @override
  void initState() {
    super.initState();
    // ChallengeManager.resetDaily();
    // ChallengeManager.resetWeekly();
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
    final challengeService = ChallengeService();
    try {
      final challenges = await challengeService.fetchChallenges();
      if (mounted) {
        setState(() {
          _dailyChallenges = challenges['daily']!;
          _weeklyChallenges = challenges['weekly']!;
          _allTimeChallenges = challenges['allTime']!;
          _isLoading = false;
          dailyReset = ChallengeManager.getNextDailyReset();
          weeklyReset = ChallengeManager.getNextWeeklyReset();
        });
      }
    } catch (e) {
      // Handle error, e.g., show a snackbar
      debugPrint("Failed to fetch challenges: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _incrementChallenge(Challenge c) async {
    final challengeService = ChallengeService();
    final success = await challengeService.incrementChallenge(c);
    if (success) {
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
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Challenges",
          style: GoogleFonts.lexend(color: const Color(0xFFFBBF18)),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.orange,
            height: 4.0,
          )
        ),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
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
