import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class ProfileService extends ChangeNotifier {
  static const String _key = 'safea_profile';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Map<String, dynamic> getProfile() {
    final data = _prefs?.getString(_key);
    if (data != null) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {}
    }
    final defaultProfile = {
      'name': 'Pengguna',
      'email': 'user@email.com',
      'points': 1250,
      'streak': 5,
      'lastScore': 78,
      'previousScore': 70,
      'lastSession': {
        'date': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'doctor': 'Dr. Sarah M.',
      },
    };
    saveProfile(defaultProfile);
    return defaultProfile;
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _prefs?.setString(_key, jsonEncode(profile));
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final current = getProfile();
    if (updates.containsKey('lastScore') &&
        updates['lastScore'] != current['lastScore']) {
      updates['previousScore'] = current['lastScore'];
    }
    final updated = {...current, ...updates};
    await saveProfile(updated);
  }

  Future<void> addPoints(int amount) async {
    final current = getProfile();
    await updateProfile({'points': (current['points'] as int) + amount});
  }
}
