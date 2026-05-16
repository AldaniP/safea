import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class RemindersService extends ChangeNotifier {
  static const String _key = 'safea_reminders';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> getReminders() {
    final data = _prefs?.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    final defaultReminders = [
      {
        'id': '1',
        'title': 'Waktunya Asesmen Mingguan (DASS-21)',
        'time': 'Hari ini, 19:00',
        'type': 'assessment',
        'isCompleted': false,
        'actionLink': '/dass21',
        'actionLabel': 'Mulai',
      },
      {
        'id': '2',
        'title': 'Latihan Pernapasan 4-7-8',
        'time': 'Hari ini, 12:00',
        'type': 'breathing',
        'isCompleted': false,
        'actionLink': '/calm',
        'actionLabel': 'Mulai',
      },
      {
        'id': '3',
        'title': 'Minum Obat (Vitamin D)',
        'time': 'Hari ini, 08:00',
        'type': 'medication',
        'isCompleted': true,
      },
    ];
    saveReminders(defaultReminders);
    return defaultReminders;
  }

  Future<void> saveReminders(
    List<Map<String, dynamic>> reminders,
  ) async {
    await _prefs?.setString(_key, jsonEncode(reminders));
    notifyListeners();
  }

  Future<void> markReminderCompleted(String id) async {
    final reminders = getReminders();
    final index = reminders.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      reminders[index]['isCompleted'] = true;
      await saveReminders(reminders);
    }
  }

  Future<void> addReminder(Map<String, dynamic> reminder) async {
    final reminders = getReminders();
    final newReminder = {
      ...reminder,
      'id': Random().nextInt(1000000).toString(),
      'isCompleted': false,
    };
    reminders.add(newReminder);
    await saveReminders(reminders);
  }
}
