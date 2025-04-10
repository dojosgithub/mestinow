import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../objectbox.g.dart';
import '../models/event_log.dart';
// import 'package:objectbox/objectbox.dart';

class DatabaseService {
  late final Store store;
  late final Box<EventLog> eventLogBox;
  // static Future<void> initialize() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   isar = await Isar.open(
  //     [EventLogSchema],
  //     directory: dir.path,
  //   );
  // }

  DatabaseService._create(this.store) {
    // TODO: Initialize the database
    eventLogBox = store.box<EventLog>();
  }

  static Future<DatabaseService> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(dir.path, "mestinow.db"),
    ); //ObjectBox.create(getObjectBoxModel(), directory: dir.path);
    return DatabaseService._create(store);
  }

  // Symptom logging methods
  Future<void> logEvent(String eventType) async {
    final eventLog = EventLog(timestamp: DateTime.now(), eventType: eventType);

    eventLogBox.put(eventLog);

    // await isar.writeTxn(() async {
    //   await isar.eventLogs.put(eventLog);
    // });
  }

  // Query methods
  // Future<List<EventLog>> getRecentEvents(Duration duration) async {
  //   final cutoff = DateTime.now().subtract(duration);
  //   return await isar.eventLogs
  //       .filter()
  //       .timestampGreaterThan(cutoff)
  //       .findAll();
  // }

  Future<List<EventLog>> getEventsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    //   return await isar.eventLogs
    //       .filter()
    //       .timestampBetween(start, end)
    //       .sortByTimestampDesc()
    //       .findAll();
    // }
    final query =
        eventLogBox
            .query(
              EventLog_.timestamp.between(
                start.millisecondsSinceEpoch,
                end.millisecondsSinceEpoch,
              ),
            )
            .order(EventLog_.timestamp, flags: Order.descending)
            .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<EventLog?> getLastMedIntake() async {
    final query =
        eventLogBox
            .query(EventLog_.eventType.equals('medMestinon'))
            .order(EventLog_.timestamp, flags: Order.descending)
            .build();
    final results = query.findFirst();
    query.close();
    return results;
  }

  Future<void> updateEventTime(int eventId, DateTime newTime) async {
    final eventLog = eventLogBox.get(eventId);
    if (eventLog != null) {
      eventLog.timestamp = newTime;
      eventLogBox.put(eventLog);
    }
  }

  Future<void> deleteEvent(int id) async {
    eventLogBox.remove(id);
  }
}
