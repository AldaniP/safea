import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safea/data/vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await VaultService.init();
  });

  group('VaultService - Safety Plan', () {
    test('getSafetyPlan returns default plan when empty', () {
      final plan = VaultService.getSafetyPlan();
      expect(plan['warnings'], isNotEmpty);
      expect(plan['copingStrategies'], isNotEmpty);
      expect(plan['contacts'], isNotEmpty);
    });

    test('saveSafetyPlan saves data correctly', () async {
      final customPlan = {
        'warnings': ['Custom Warning'],
        'copingStrategies': ['Custom Strategy'],
        'contacts': [
          {'title': 'Test', 'phone': '123'},
        ],
      };
      await VaultService.saveSafetyPlan(customPlan);
      final savedPlan = VaultService.getSafetyPlan();
      expect(savedPlan['warnings'][0], 'Custom Warning');
    });
  });

  group('VaultService - Vault', () {
    test('isVaultSetup returns false initially', () {
      expect(VaultService.isVaultSetup(), isFalse);
    });

    test('setupVault sets up PIN and empty notes', () async {
      await VaultService.setupVault('1234');
      expect(VaultService.isVaultSetup(), isTrue);
      expect(VaultService.verifyPin('1234'), isTrue);
      expect(VaultService.getNotes(), isEmpty);
    });

    test('verifyPin returns false for wrong PIN', () async {
      await VaultService.setupVault('1234');
      expect(VaultService.verifyPin('5678'), isFalse);
    });

    test('addNote adds a note successfully', () async {
      await VaultService.setupVault('1234');
      final success = await VaultService.addNote('Test Note');
      expect(success, isTrue);
      final notes = VaultService.getNotes();
      expect(notes.length, 1);
      expect(notes[0]['content'], 'Test Note');
    });

    test('addNote with file adds successfully', () async {
      await VaultService.setupVault('1234');
      final file = {
        'name': 'test.txt',
        'type': 'text/plain',
        'data': 'base64data',
      };
      final success = await VaultService.addNote('Test Note', file);
      expect(success, isTrue);
      final notes = VaultService.getNotes();
      expect(notes[0]['file']['name'], 'test.txt');
    });

    test('panicWipe clears PIN and notes', () async {
      await VaultService.setupVault('1234');
      await VaultService.addNote('Test Note');

      await VaultService.panicWipe();

      expect(VaultService.isVaultSetup(), isFalse);
      expect(VaultService.getNotes(), isEmpty);
    });
  });
}
