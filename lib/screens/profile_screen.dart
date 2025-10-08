import 'package:flutter/material.dart';
import 'friend_screen.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFF667DB5),
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'youremail@example.com',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Card(
              //   child: ListTile(
              //     leading: const Icon(Icons.info_outline),
              //     title: const Text('Account type'),
              //     subtitle: const Text('Standard'),
              //   ),
              // ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.group),
                  label: const Text('Friends'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF667DB5)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Friend()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change password'),
                  onTap: () {
                    // Placeholder - hook up change password flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change password tapped')),
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
