import 'package:objectbox/objectbox.dart';

@Entity()
class EventLog {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime timestamp;

  // @enumerated
  // EventType eventType = EventType.medMestinon; // e.g., 'ptosis', 'vision', etc.
  String eventType;

  EventLog({
    required this.timestamp,
    required this.eventType,
  });
}

enum EventType {
  medMestinon,
  // med_prednisolone,
  // med_prednisolone_and_mestinon,
  // med_prednisolone_and_mestinon_and_steroid,
  symptomPtosis,
  symptomVision,
  symptomWeakness,
  symptomNeck,
  symptomBreathing,
  symptomWalking,
}
