import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  bool _useMetric = true;
  bool _enableAI = true;
  bool _notifications = true;
  bool _isLoading = true;

  bool get useMetric => _useMetric;
  bool get enableAI => _enableAI;
  bool get notifications => _notifications;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    final metric = await _storage.read(key: 'use_metric');
    final ai = await _storage.read(key: 'enable_ai');
    final notif = await _storage.read(key: 'notifications');

    _useMetric = metric != 'false';
    _enableAI = ai != 'false';
    _notifications = notif != 'false';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUseMetric(bool value) async {
    _useMetric = value;
    await _storage.write(key: 'use_metric', value: value.toString());
    notifyListeners();
  }

  Future<void> setEnableAI(bool value) async {
    _enableAI = value;
    await _storage.write(key: 'enable_ai', value: value.toString());
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    await _storage.write(key: 'notifications', value: value.toString());
    notifyListeners();
  }
}
