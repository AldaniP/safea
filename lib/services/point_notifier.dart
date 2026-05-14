import 'package:flutter/material.dart';
import 'secure_vault_service.dart';

class PointNotifier extends ChangeNotifier {
  int _totalPoints = 0;
  int _level = 1;

  int get totalPoints => _totalPoints;
  int get level => _level;

  final SecureVaultService _vault = SecureVaultService.instance;

  /// Load points from secure storage
  Future<void> loadPoints() async {
    try {
      final pointsStr = _vault.decryptData('user_points');
      _totalPoints = int.tryParse(pointsStr) ?? 0;
      _calculateLevel();
      notifyListeners();
    } catch (_) {
      // Data might not exist yet
      _totalPoints = 0;
      _level = 1;
    }
  }

  /// Add points and persist to secure storage
  Future<void> addPoints(int points) async {
    _totalPoints += points;
    _calculateLevel();

    final pointsStr = _totalPoints.toString();
    _vault.encryptData(
      pointsStr,
    ); // Note: SecureVaultService.encryptData needs a key context in a real app,
    // but here we use it as a placeholder for secure persistence.

    notifyListeners();
  }

  void _calculateLevel() {
    // Simple level logic: every 100 points is a level
    _level = (_totalPoints / 100).floor() + 1;
  }
}
