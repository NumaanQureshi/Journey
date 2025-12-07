import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'side_menu.dart';

// ------------------------------------------------------------
//  SCORE SYSTEM (Mock – until backend is implemented)
// ------------------------------------------------------------
class ScoreManager {
  static int _score = 0;

  // Track daily, weekly, and monthly progress
  static int _dailyCompleted = 0;
  static int _weeklyCompleted = 0;

  // Track last reset timestamps
  static DateTime _lastDailyReset = DateTime.now();
  static DateTime _lastWeeklyReset = DateTime.now();
  static DateTime _lastMonthlyReset = DateTime.now();

  static int get score => _score;
  static int get dailyCompleted => _dailyCompleted;
  static int get weeklyCompleted => _weeklyCompleted;

  // -----------------------------
  // EXERCISE POINTS
  // -----------------------------
  static void addExerciseEasy() => _score += 100;
  static void addExerciseMedium() => _score += 250;
  static void addExerciseAdvanced() => _score += 500;

  // -----------------------------
  // DAILY CHALLENGES
  // Base = +300 each
  // Bonus = +1500 when completing all 5
  // -----------------------------
  static void completeDailyChallenge() {
    _checkDailyReset();

    if (_dailyCompleted < 5) {
      _dailyCompleted++;
      _score += 300;

      if (_dailyCompleted == 5) {
        _score += 1500; // bonus
      }
    }
  }

  static void _checkDailyReset() {
    DateTime now = DateTime.now();
    if (!_isSameDay(now, _lastDailyReset)) {
      resetDaily();
      _lastDailyReset = now;
    }
  }

  static void resetDaily() {
    _dailyCompleted = 0;
  }

  // -----------------------------
  // WEEKLY CHALLENGES
  // Base = +1000 each
  // Bonus = +5000 when completing all 3
  // -----------------------------
  static void completeWeeklyChallenge() {
    _checkWeeklyReset();

    if (_weeklyCompleted < 3) {
      _weeklyCompleted++;
      _score += 1000;

      if (_weeklyCompleted == 3) {
        _score += 5000; // bonus
      }
    }
  }

  static void _checkWeeklyReset() {
    DateTime now = DateTime.now();
    if (!_isSameWeek(now, _lastWeeklyReset)) {
      resetWeekly();
      _lastWeeklyReset = now;
    }
  }

  static void resetWeekly() {
    _weeklyCompleted = 0;
  }

  // -----------------------------
  // MONTHLY LEADERBOARD RESET
  // -----------------------------
  static void checkMonthlyReset() {
    DateTime now = DateTime.now();
    if (!_isSameMonth(now, _lastMonthlyReset)) {
      resetLeaderboard();
      _lastMonthlyReset = now;
    }
  }

  static void resetLeaderboard() {
    _score = 0;
    resetDaily();
    resetWeekly();
  }

  // -----------------------------
  // HELPER FUNCTIONS
  // -----------------------------
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isSameWeek(DateTime a, DateTime b) {
    // Week starts on Monday
    DateTime mondayA = a.subtract(Duration(days: a.weekday - 1));
    DateTime mondayB = b.subtract(Duration(days: b.weekday - 1));
    return _isSameDay(mondayA, mondayB);
  }

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  // -----------------------------
  // RESET EVERYTHING MANUALLY
  // -----------------------------
  static void resetAll() {
    _score = 0;
    _dailyCompleted = 0;
    _weeklyCompleted = 0;
    _lastDailyReset = DateTime.now();
    _lastWeeklyReset = DateTime.now();
    _lastMonthlyReset = DateTime.now();
  }
}

// ------------------------------------------------------------
//  LEADERBOARD STRUCTURE + MEDAL SYSTEM
// ------------------------------------------------------------
enum Medal { gold, silver, bronze, none }

class LeaderboardEntry {
  final String name;

  // TODO: Implement a dynamic point system for score calculation (default is at 0)
  final int score;

  final bool isCurrentUser;
  final bool isFriend;

  LeaderboardEntry({
    required this.name,
    required this.score,
    this.isCurrentUser = false,
    this.isFriend = false,
  });

  // Determine medal based on rank position
  Medal getMedal(int rank) {
    switch (rank) {
      case 1:
        return Medal.gold;
      case 2:
        return Medal.silver;
      case 3:
        return Medal.bronze;
      default:
        return Medal.none;
    }
  }

  // Set the medal colors
  Color medalColor(Medal medal) {
    switch (medal) {
      case Medal.gold:
        return const Color(0xFFFFD700);
      case Medal.silver:
        return const Color(0xFFC0C0C0);
      case Medal.bronze:
        return const Color(0xFFCD7F32);
      default:
        return Colors.white70;
    }
  }
}

// ------------------------------------------------------------
//  TEMPORARY MOCK DATA (Until Backend Is Implemented)
// TODO: Replace with REAL dynamic data from backend.
// TODO: Fetch user score, friends, and other users via API.
// ------------------------------------------------------------
List<LeaderboardEntry> getVisibleLeaderboard() {
  return [
    LeaderboardEntry(
      name: 'You', // the current user
      score: ScoreManager.score,
      isCurrentUser: true,
    ),
  ];
}

// ------------------------------------------------------------
//  Ranking Logic (Supports ties)
// TODO: Ranking should eventually come from backend to ensure fairness.
// ------------------------------------------------------------
List<Map<String, dynamic>> computeRanks(List<LeaderboardEntry> entries) {
  entries.sort((a, b) => b.score.compareTo(a.score));

  List<Map<String, dynamic>> rankedList = [];
  int currentRank = 1;

  for (int i = 0; i < entries.length; i++) {
    if (i > 0 && entries[i].score == entries[i - 1].score) {
      rankedList.add({
        'entry': entries[i],
        'rank': rankedList[i - 1]['rank'],
      });
    } else {
      rankedList.add({
        'entry': entries[i],
        'rank': currentRank,
      });
    }
    currentRank++;
  }

  return rankedList;
}

// ------------------------------------------------------------
// LEADERBOARD UI
// ------------------------------------------------------------
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Timer? _timer;
  Duration _timeUntilReset = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeUntilReset();

    // Update countdown every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _calculateTimeUntilReset();
    });
  }

  void _calculateTimeUntilReset() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    setState(() {
      _timeUntilReset = nextMonth.difference(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return "${days}d ${hours}H";
  }

  Widget _buildMonthlyResetBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Monthly reset in ${_formatDuration(_timeUntilReset)}",
              style: GoogleFonts.kanit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> data) {
    final LeaderboardEntry entry = data['entry'];
    final int rank = data['rank'];
    final Medal medal = entry.getMedal(rank);

    final backgroundColor = entry.isCurrentUser
        ? const Color(0xFF667DB5).withOpacity(0.2)
        : Colors.grey[900];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: entry.isCurrentUser
            ? Border.all(color: const Color(0xFFFBBF18), width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        leading: SizedBox(
          width: 50,
          child: Row(
            children: [
              Text(
                '$rank.',
                style: GoogleFonts.lexend(
                  color: medal != Medal.none
                      ? entry.medalColor(medal)
                      : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.circle,
                color: medal != Medal.none
                    ? entry.medalColor(medal)
                    : Colors.white24,
                size: medal != Medal.none ? 16 : 12,
              ),
            ],
          ),
        ),
        title: Text(
          entry.name,
          style: GoogleFonts.lexend(
            color: medal != Medal.none
                ? entry.medalColor(medal)
                : Colors.white,
            fontWeight:
                entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          entry.score.toString(),
          style: GoogleFonts.kanit(
            color: const Color(0xFFFBBF18),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Real-time monthly reset check
    ScoreManager.checkMonthlyReset();

    final rankedList = computeRanks(getVisibleLeaderboard());

    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Leaderboard'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFFFBBF18)),
        title: Text(
          'Leaderboard',
          style: GoogleFonts.lexend(
            color: const Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Monthly reset countdown banner
          _buildMonthlyResetBanner(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Leaderboard Ranking',
              style: GoogleFonts.kanit(
                color: const Color(0xFF667DB5),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          // Leaderboard List
          Expanded(
            child: ListView.builder(
              itemCount: rankedList.length,
              itemBuilder: (context, index) =>
                  _buildLeaderboardTile(rankedList[index]),
            ),
          ),
        ],
      ),
    );
  }
}
