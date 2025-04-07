
class Symptom {
  final String code;
  final String icon;
  // final Map<String, String> displayNames;

  const Symptom({
    required this.code,
    required this.icon,
    // required this.displayNames,
  });

  String getDisplayName(l10n) {
    switch (code) {
      case 'symPtosis':
        return l10n.symPtosis;
      case 'symVision':
        return l10n.symVision;
      case 'symWeakness':
        return l10n.symWeakness;
      case 'symNeck':
        return l10n.symNeck;
      case 'symBreathing':
        return l10n.symBreathing;
      case 'symWalking':
        return l10n.symWalking;
      default:
        return code;
    }
  }


  static const List<Symptom> allSymptoms = [
    Symptom(
      code: 'symPtosis',
      icon: 'assets/icons/ptosis.png',
    ),
    Symptom(
      code: 'symVision',
      icon: 'assets/icons/vision.png',
    ),
    Symptom(
      code: 'symWeakness',
      icon: 'assets/icons/weakness.png',
    ),
    Symptom(
      code: 'symNeck',
      icon: 'assets/icons/neck.png',
    ),
    Symptom(
      code: 'symBreathing',
      icon: 'assets/icons/breathing.png',
    ),
    Symptom(
      code: 'symWalking',
      icon: 'assets/icons/walking.png',
    ),
  ];
} 