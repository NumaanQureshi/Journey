import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Workout extends StatelessWidget {
  const Workout({super.key});

  void _notImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Not Implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(
          'Workout',
          style: GoogleFonts.lexend(
            color: const Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/workout_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularIconButton(
                        context,
                        icon: Icons.timer_outlined,
                        tooltip: 'Timer',
                        onPressed: () => _notImplemented(context),
                        color: const Color(0xFFBF6A02),
                      ),
                      _buildCircularIconButton(
                        context,
                        icon: Icons.history,
                        tooltip: 'Sessions',
                        onPressed: () => _notImplemented(context),
                        color: Colors.blue,
                      ),
                      _buildCircularIconButton(
                        context,
                        icon: Icons.list_alt,
                        tooltip: 'Plans',
                        onPressed: () => _notImplemented(context),
                        color: const Color(0xFF667DB5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(BuildContext context, {required IconData icon, required String tooltip, required VoidCallback onPressed, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        iconSize: 48,
        color: Colors.white,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}