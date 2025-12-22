import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'side_menu.dart';

class UserAnalyticsScreen extends StatelessWidget {
  const UserAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Analytics'),
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.lexend(color: const Color(0xFFFBBF18)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.blue),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummarySection(),
            const SizedBox(height: 24),
            _buildChartSection(
              title: 'Workout Frequency (Last 4 Weeks)',
              chartPlaceholder: _buildBarChartPlaceholder(),
            ),
            const SizedBox(height: 24),
            _buildChartSection(
              title: 'Bench Press Progress (1RM Est.)',
              chartPlaceholder: _buildLineChartPlaceholder(),
            ),
            const SizedBox(height: 24),
            _buildTopExercises(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _StatCard(
          label: 'Total Workouts',
          value: '128',
          icon: Icons.fitness_center,
          color: Colors.redAccent,
        ),
        _StatCard(
          label: 'Total Volume',
          value: '1.2M lbs',
          icon: Icons.scale,
          color: Colors.greenAccent,
        ),
        _StatCard(
          label: 'Time Spent',
          value: '96h 30m',
          icon: Icons.timer,
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildChartSection({required String title, required Widget chartPlaceholder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: chartPlaceholder,
        ),
      ],
    );
  }

  Widget _buildTopExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Frequent Exercises',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFF2C2C2C),
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.orange),
                title: Text('Barbell Bench Press', style: TextStyle(color: Colors.white)),
                trailing: Text('102 sets', style: TextStyle(color: Colors.white70)),
              ),
              ListTile(
                leading: Icon(Icons.accessibility_new, color: Colors.blue),
                title: Text('Squat', style: TextStyle(color: Colors.white)),
                trailing: Text('88 sets', style: TextStyle(color: Colors.white70)),
              ),
              ListTile(
                leading: Icon(Icons.align_vertical_bottom, color: Colors.red),
                title: Text('Deadlift', style: TextStyle(color: Colors.white)),
                trailing: Text('75 sets', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartPlaceholder() {
    return const Center(child: Text('Bar Chart Placeholder', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildLineChartPlaceholder() {
    return const Center(child: Text('Line Chart Placeholder', style: TextStyle(color: Colors.white54)));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: const Color(0xFF2C2C2C),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
