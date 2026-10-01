import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'settings/account_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: GoogleFonts.raleway(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('General'),
          // TODO: Add "Fitness Settings", 'AI Settings', and "Notifications"
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white70),
            title: const Text('Account Settings', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            onTap: () {},
          ),
          _buildSectionHeader('Information'),
          // TODO: Add "About Us" and "Privacy"
        ],
      ),
    );
  }
}