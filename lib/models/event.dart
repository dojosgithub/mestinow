class Event {
  final String code;
  final String icon;
  final String type;
  // final Map<String, String> displayNames;

  const Event({
    required this.code,
    required this.icon,
    required this.type,
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
      case 'medMestinon':
        return l10n.medMestinon;
      case 'symChew':
        return l10n.symChew;
      case 'symSwallow':
        return l10n.symSwallow;
      case 'symSpeech':
        return l10n.symSpeech;
      case 'symFacial':
        return l10n.symFacial;
      case 'symArm':
        return l10n.symArm;
      case 'symHand':
        return l10n.symHand;
      default:
        return code;
    }
  }

  static Event? findByCode(String code) {
    try {
      return allEvents.firstWhere((symptom) => symptom.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<Event> getSymptoms() {
    return allEvents.where((event) => event.type == 'sym').toList();
  }

  static List<Event> getMedications() {
    return allEvents.where((event) => event.type == 'med').toList();
  }

  static const List<Event> allEvents = [
    Event(
      code: 'medMestinon',
      icon: 'assets/icons/medMestinon.png',
      type: 'med',
    ),
    Event(code: 'symPtosis', icon: 'assets/icons/ptosis.png', type: 'sym'),
    Event(code: 'symVision', icon: 'assets/icons/vision.png', type: 'sym'),
    Event(code: 'symWeakness', icon: 'assets/icons/weakness.png', type: 'sym'),
    Event(code: 'symNeck', icon: 'assets/icons/neck.png', type: 'sym'),
    Event(
      code: 'symBreathing',
      icon: 'assets/icons/breathing.png',
      type: 'sym',
    ),
    Event(code: 'symWalking', icon: 'assets/icons/walking.png', type: 'sym'),
    Event(code: 'symChew', icon: 'assets/icons/chewing.png', type: 'sym'),
    Event(code: 'symSwallow', icon: 'assets/icons/swallowing.png', type: 'sym'),
    Event(code: 'symSpeech', icon: 'assets/icons/speech.png', type: 'sym'),
    Event(code: 'symFacial', icon: 'assets/icons/facial.png', type: 'sym'),
    Event(code: 'symArm', icon: 'assets/icons/arm.png', type: 'sym'),
    Event(code: 'symHand', icon: 'assets/icons/hand.png', type: 'sym'),
  ];
}
