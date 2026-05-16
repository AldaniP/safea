import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class VaultService {
  static const String _planKey = 'safea_safety_plan';
  static const String _pinKey = 'safea_vault_pin';
  static const String _notesKey = 'safea_vault_notes';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Safety Plan ---

  static Map<String, dynamic> getSafetyPlan() {
    final data = _prefs?.getString(_planKey);
    if (data != null) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {}
    }
    final defaultPlan = {
      'warnings': [
        'Napas mulai terasa sesak dan pendek',
        'Muncul dorongan untuk menyakiti diri',
        'Perasaan terisolasi yang luar biasa',
      ],
      'copingStrategies': [
        'Lakukan teknik pernapasan 4-7-8 selama 5 putaran',
        'Pegang es batu atau cuci muka dengan air sangat dingin',
        'Hubungi nomor kontak darurat di bawah',
      ],
      'contacts': [
        {
          'title': 'Kakak (Rani)',
          'desc': 'Bisa dihubungi 24 Jam',
          'phone': '+628123456789',
        },
        {
          'title': 'Terapis (Dr. Sarah)',
          'desc': 'Senin - Jumat, 09:00 - 17:00',
          'phone': '+628987654321',
        },
      ],
    };
    saveSafetyPlan(defaultPlan);
    return defaultPlan;
  }

  static Future<void> saveSafetyPlan(Map<String, dynamic> plan) async {
    await _prefs?.setString(_planKey, jsonEncode(plan));
  }

  // --- Vault ---

  static bool isVaultSetup() {
    return _prefs?.containsKey(_pinKey) ?? false;
  }

  static Future<void> setupVault(String pin) async {
    await _prefs?.setString(_pinKey, pin);
    await _prefs?.setString(_notesKey, jsonEncode([]));
  }

  static bool verifyPin(String pin) {
    return _prefs?.getString(_pinKey) == pin;
  }

  static List<Map<String, dynamic>> getNotes() {
    final data = _prefs?.getString(_notesKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  static Future<bool> addNote(
    String content, [
    Map<String, dynamic>? file,
  ]) async {
    final notes = getNotes();
    final Map<String, dynamic> newNote = {
      'id': Random().nextInt(1000000).toString(),
      'date': DateTime.now().toIso8601String(),
      'content': content,
    };
    if (file != null) {
      newNote['file'] =
          file; // Note: For a real app, storing large base64 in SharedPrefs is bad practice.
    }
    notes.insert(0, newNote);

    try {
      await _prefs?.setString(_notesKey, jsonEncode(notes));
      return true;
    } catch (e) {
      return false; // Storage full or encoding failed
    }
  }

  static Future<void> panicWipe() async {
    await _prefs?.remove(_pinKey);
    await _prefs?.setString(_notesKey, jsonEncode([]));
  }
}
