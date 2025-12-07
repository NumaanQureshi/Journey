import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'side_menu.dart';


// LEADERBOARD DATA STRUCTURE + MEDAL SYSTEM
enum Medal { gold, silver, bronze, none }

class LeaderboardEntry {
  final String name;
  final int score; // TODO: Implement a dynamic point system for score calculation (default is at 0)
  final bool isCurrentUser;
  final bool isFriend;

  LeaderboardEntry({
    required this.name,
    required this.score,
    this.isCurrentUser = false,
    this.isFriend = false,
  });

  /// Determine medal based on rank position
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

  /// Set the medal colors
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


// TEMPORARY MOCK DATA (Until Backend Is Implemented)
// Default will always start with the user
// TODO: Replace this mock list with REAL dynamic data from backend.
// When backend is ready:
// - fetch all friends + user ranking
// - compute scores server-side
// - fetch global leaderboard if needed
// since it the user first time using the app, their score is 0 always by default
final List<LeaderboardEntry> allUsers = [
  LeaderboardEntry(
    name: 'You', // the current user
    score: 0,
    isCurrentUser: true,
  )
];


// Returns ONLY visible users for the leaderboard
// TODO: Implement real friend filtering:
// - Query backend for the user’s friend list
// - Merge "you + friends" into a single list
List<LeaderboardEntry> getVisibleLeaderboard(List<LeaderboardEntry> users) {
  return users; // currently ONLY the user is shown
}


// Ranking Logic (also Supports ties)
// TODO: Ranking should eventually come from backend to avoid
// cheating and ensure fairness.
List<Map<String, dynamic>> computeRanks(List<LeaderboardEntry> entries) {
  entries.sort((a, b) => b.score.compareTo(a.score));

  List<Map<String, dynamic>> rankedList = [];
  int currentRank = 1;

  for (int i = 0; i < entries.length; i++) {
    // Give same rank if tied
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


// UI SCREEN
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Widget _buildLeaderboardTile(Map<String, dynamic> data) {
    final LeaderboardEntry entry = data['entry'];
    final int rank = data['rank'];
    final Medal medal = entry.getMedal(rank);

    final backgroundColor = entry.isCurrentUser
        ? const Color(0xFF667DB5).withValues(alpha: 0.2)
        : Colors.grey[900];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: entry.isCurrentUser
            ? Border.all(color: const Color(0xFFFBBF18), width: 1.5)
            : null,
        boxShadow: entry.isCurrentUser
            ? [
                BoxShadow(
                  color: const Color(0xFFFBBF18).withValues(alpha: 0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),

        /// Rank + Medal Icon
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
              if (medal != Medal.none)
                Icon(
                  Icons.circle,
                  color: entry.medalColor(medal),
                  size: 16,
                )
              else
                const Icon(
                  Icons.circle,
                  color: Colors.white24,
                  size: 12,
                ),
            ],
          ),
        ),

        /// Player Name
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

        /// Player Score
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
    final visibleUsers = getVisibleLeaderboard(allUsers);
    final rankedList = computeRanks(visibleUsers);

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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Leaderboard Ranking',
              style: GoogleFonts.kanit(
                color: const Color(0xFF667DB5),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          /// Leaderboard List
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
