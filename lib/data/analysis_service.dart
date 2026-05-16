import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisService {
  static const String _key = 'safea_analysis_history';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<Map<String, dynamic>> getAnalysisHistory() {
    final data = _prefs?.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  static Future<void> saveAnalysisRecord(Map<String, dynamic> record) async {
    final history = getAnalysisHistory();
    final newRecord = {
      ...record,
      'id': Random().nextInt(1000000).toString(),
      'date': DateTime.now().toIso8601String(),
    };
    history.add(newRecord);
    await _prefs?.setString(_key, jsonEncode(history));
  }

  static Future<void> clearAnalysisHistory() async {
    await _prefs?.remove(_key);
  }
}
