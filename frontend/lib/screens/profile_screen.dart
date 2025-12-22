import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friend_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    setState(() {
      username = user?.profile?.name ?? user?.username ?? 'Your Name';
    });
  }

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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.orange,
            height: 4.0,
          )
        ),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          SizedBox(height: 100),
          Center(
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
                  Text(
                    username ?? 'Your Name',
                    style: const TextStyle(
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
                      label: const Text('Edit Profile', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
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
                          onPressed: () async {
                            // Clear user data and token
                            await context.read<UserProvider>().clearUser();
                            
                            if (!mounted) return;
                            
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
        ] 
      ),
    );
  }
}
