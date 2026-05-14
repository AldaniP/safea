import 'dart:math';

class AffirmationService {
  AffirmationService._privateConstructor();
  static final AffirmationService _instance =
      AffirmationService._privateConstructor();
  static AffirmationService get instance => _instance;

  final List<String> _affirmations = [
    'Kamu mampu melakukan hal-hal luar biasa.',
    'Setiap hari adalah awal yang baru.',
    'Kamu lebih kuat dari kecemasanmu.',
    'Tidak apa-apa untuk istirahat sejenak.',
    'Perasaanmu itu valid.',
    'Tarik napas kedamaian, embuskan stres.',
    'Langkah kecil tetaplah sebuah kemajuan.',
  ];

  /// Returns a random affirmation for the day.
  /// In a real app, this could be tied to the date or user's emotional state.
  Future<String> getDailyAffirmation() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final random = Random();
    return _affirmations[random.nextInt(_affirmations.length)];
  }
}
