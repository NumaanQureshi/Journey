import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _notImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        title: Text(
          'Settings',
          style: GoogleFonts.lexend(
            color: const Color(0xFFFBBF18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: const Color.fromARGB(255, 26, 26, 26),
        child: ListView(
          children: [
            _buildSectionHeader('General'),
            _buildSettingsTile(
              context,
              icon: Icons.account_circle,
              title: 'Account Management',
              onTap: () => _notImplemented(context, 'Account Management'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () => _notImplemented(context, 'Notifications'),
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _buildSectionHeader('App Settings'),
            _buildSettingsTile(
              context,
              icon: Icons.fitness_center,
              title: 'Fitness Settings',
              onTap: () => _notImplemented(context, 'Fitness Settings'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.smart_toy,
              title: 'AI Settings',
              onTap: () => _notImplemented(context, 'AI Settings'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy',
              onTap: () => _notImplemented(context, 'Privacy'),
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _buildSectionHeader('Information'),
            _buildSettingsTile(
              context,
              icon: Icons.info,
              title: 'About Us',
              onTap: () => _notImplemented(context, 'About Us'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: GoogleFonts.raleway(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}