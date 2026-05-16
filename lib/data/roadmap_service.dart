import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class RoadmapService extends ChangeNotifier {
  static const String _key = 'safea_roadmap';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> getRoadmap() {
    final data = _prefs?.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    final initialSteps = [
      {
        'id': 1,
        'title': 'Latihan Pernapasan Dasar',
        'desc': 'Selesaikan 3 sesi pernapasan 4-7-8.',
        'completed': false,
      },
      {
        'id': 2,
        'title': 'Jurnal Gratitude',
        'desc': 'Tulis 3 hal yang disyukuri hari ini.',
        'completed': false,
      },
      {
        'id': 3,
        'title': 'Sesi Grounding 5-4-3-2-1',
        'desc': 'Gunakan fitur grounding saat merasa cemas.',
        'completed': false,
      },
      {
        'id': 4,
        'title': 'Afirmasi Pagi',
        'desc': 'Ucapkan mantra positif selama 3 hari berturut-turut.',
        'completed': false,
      },
      {
        'id': 5,
        'title': 'Mindfulness Berjalan',
        'desc': 'Fokus pada langkah kaki selama 10 menit.',
        'completed': false,
      },
    ];
    saveRoadmap(initialSteps);
    return initialSteps;
  }

  Future<void> saveRoadmap(List<Map<String, dynamic>> steps) async {
    await _prefs?.setString(_key, jsonEncode(steps));
  }

  Future<List<Map<String, dynamic>>> toggleRoadmapStep(int id) async {
    final steps = getRoadmap();
    final index = steps.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      steps[index]['completed'] = !(steps[index]['completed'] as bool);
      await saveRoadmap(steps);
      notifyListeners();
    }
    return steps;
  }
}
