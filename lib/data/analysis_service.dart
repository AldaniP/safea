import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class AnalysisService extends ChangeNotifier {
  static const String _key = 'safea_analysis_history';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Map<String, dynamic>> getAnalysisHistory() {
    final data = _prefs?.getString(_key);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveAnalysisRecord(Map<String, dynamic> record) async {
    final history = getAnalysisHistory();
    final newRecord = {
      ...record,
      'id': Random().nextInt(1000000).toString(),
      'date': DateTime.now().toIso8601String(),
    };
    history.add(newRecord);
    await _prefs?.setString(_key, jsonEncode(history));
    notifyListeners();
  }

  Future<void> clearAnalysisHistory() async {
    await _prefs?.remove(_key);
    notifyListeners();
  }
}
