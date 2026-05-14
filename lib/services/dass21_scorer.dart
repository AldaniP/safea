enum DassSeverity { normal, mild, moderate, severe, extremelySevere }

class Dass21Scorer {
  // Item indices (1-based per official DASS-21 form)
  static const depressionItems = [3, 5, 10, 13, 16, 17, 21];
  static const anxietyItems = [2, 4, 7, 9, 15, 19, 20];
  static const stressItems = [1, 6, 8, 11, 12, 14, 18];

  /// Calculates the final score (raw sum * 2) for a subscale
  static int calculateSubscaleScore(
    Map<int, int> responses,
    List<int> itemIndices,
  ) {
    var rawSum = itemIndices.fold(
      0,
      (sum, index) => sum + (responses[index] ?? 0),
    );
    return rawSum * 2;
  }

  static DassSeverity getDepressionSeverity(int score) {
    if (score <= 9) return DassSeverity.normal;
    if (score <= 13) return DassSeverity.mild;
    if (score <= 20) return DassSeverity.moderate;
    if (score <= 27) return DassSeverity.severe;
    return DassSeverity.extremelySevere;
  }

  static DassSeverity getAnxietySeverity(int score) {
    if (score <= 7) return DassSeverity.normal;
    if (score <= 9) return DassSeverity.mild;
    if (score <= 14) return DassSeverity.moderate;
    if (score <= 19) return DassSeverity.severe;
    return DassSeverity.extremelySevere;
  }

  static DassSeverity getStressSeverity(int score) {
    if (score <= 14) return DassSeverity.normal;
    if (score <= 18) return DassSeverity.mild;
    if (score <= 25) return DassSeverity.moderate;
    if (score <= 33) return DassSeverity.severe;
    return DassSeverity.extremelySevere;
  }
}
