import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
          // TODO: Add "Account Management" and "Notifications"
          _buildSectionHeader('App Settings'),
          // TODO: Add "Fitness Settings" and 'AI Settings'
          _buildSectionHeader('Accessibility'),
          // ListTile(
          //   leading: const Icon(Icons.brightness_6),
          //   title: const Text('Theme'),
          //   subtitle: Text(_themeModeToString(themeProvider.themeMode)),
          //   onTap: () => _showThemeDialog(context, themeProvider),
          // ),
          _buildSectionHeader('Information'),
          // TODO: Add "About Us" and "Privacy"
        ],
      ),
    );
  }

  // String _themeModeToString(ThemeMode mode) {
  //   switch (mode) {
  //     case ThemeMode.light:
  //       return 'Light';
  //     case ThemeMode.dark:
  //       return 'Dark';
  //     case ThemeMode.system:
  //       return 'System Default';
  //   }
  // }

  // void _showThemeDialog(BuildContext context, ThemeProvider provider) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Choose Theme'),
  //       content: RadioGroup<ThemeMode>(
  //         groupValue: provider.themeMode,
  //         onChanged: (ThemeMode? value) {
  //           _setThemeAndPop(context, provider, value);
  //         },
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             RadioListTile<ThemeMode>(
  //               title: const Text('Light'),
  //               value: ThemeMode.light,
  //             ),
  //             RadioListTile<ThemeMode>(
  //               title: const Text('Dark'),
  //               value: ThemeMode.dark,
  //             ),
  //             RadioListTile<ThemeMode>(
  //               title: const Text('System Default'),
  //               value: ThemeMode.system,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

//   void _setThemeAndPop(
//     BuildContext context,
//     ThemeProvider provider,
//     ThemeMode? value,
//   ) {
//     if (value != null) provider.setThemeMode(value);
//     Navigator.of(context).pop();
//   }
}