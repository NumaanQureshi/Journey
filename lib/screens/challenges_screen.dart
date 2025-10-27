import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'side_menu.dart';

class Challenges extends StatelessWidget {
  const Challenges({super.key});

  Widget _buildChallengeCard(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color}) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Card(
        color: color.withValues(alpha: 0.75),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Challenges'),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(
          'Challenges',
          style: GoogleFonts.lexend(
            color: const Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/home_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Challenges', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChallengeCard(icon: Icons.directions_run, title: 'Run a mile', subtitle: '', color: const Color(0xFFBF6A02)),
                      _buildChallengeCard(icon: Icons.fitness_center, title: '300 Cals', subtitle: '', color: Colors.blue),
                      _buildChallengeCard(icon: Icons.check_circle_outline, title: '10 situps', subtitle: '', color: const Color(0xFF667DB5)),
                    ],
                  ),
                  // You can add more challenge sections like "Weekly Challenges" or "Achievements" here.
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}