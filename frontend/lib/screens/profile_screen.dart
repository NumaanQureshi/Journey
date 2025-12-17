import 'package:flutter/material.dart';
import 'friend_screen.dart';
import 'login_screen.dart';
import 'personalization_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(
          'Profile',
          style: GoogleFonts.lexend(
            color: Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Name',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.palette),
                  label: const Text('Personalize', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalizationScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.group),
                  label: const Text('Friends', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Friend()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
