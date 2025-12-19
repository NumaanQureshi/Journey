import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (settingsProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('General Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Use Metric Units', style: TextStyle(color: Colors.white)),
            value: settingsProvider.useMetric,
            onChanged: (val) => settingsProvider.setUseMetric(val),
          ),
          SwitchListTile(
            title: const Text('Enable AI Assistance', style: TextStyle(color: Colors.white)),
            value: settingsProvider.enableAI,
            onChanged: (val) => settingsProvider.setEnableAI(val),
          ),
          SwitchListTile(
            title: const Text('Enable Notifications', style: TextStyle(color: Colors.white)),
            value: settingsProvider.notifications,
            onChanged: (val) => settingsProvider.setNotifications(val),
          ),
        ],
      ),
    );
  }
}
