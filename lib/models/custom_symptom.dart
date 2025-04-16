import 'package:objectbox/objectbox.dart';

@Entity()
class CustomSymptom {
  @Id()
  int id = 0;

  late String name;


  @Property(type: PropertyType.date)
  late DateTime createdAt;

  CustomSymptom({
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
} 