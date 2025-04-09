import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../objectbox.g.dart';
import '../models/event_log.dart';
import 'dart:io';
// import 'package:objectbox/objectbox.dart';

class DatabaseService {
  late final Store store;
  late final Box<EventLog> eventLogBox;
  late final String dbPath;
  // static Future<void> initialize() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   isar = await Isar.open(
  //     [EventLogSchema],
  //     directory: dir.path,
  //   );
  // }

  DatabaseService._create(this.store, this.dbPath) {
    // TODO: Initialize the database
    eventLogBox = store.box<EventLog>();
  }

  static Future<DatabaseService> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbDirectory = p.join(dir.path, "mestinow.db");
    final store = await openStore(
      directory: dbDirectory,
    ); //ObjectBox.create(getObjectBoxModel(), directory: dir.path);
    return DatabaseService._create(store, dbDirectory);
  }

  // Export database to a file
  Future<File> exportDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final exportPath = p.join(dir.path, 'mestinow_export.db');
    
    // Copy the database file
    final sourceFile = File(p.join(dbPath, 'data.mdb'));
    final targetFile = File(exportPath);
    
    await sourceFile.copy(targetFile.path);
    return targetFile;
  }

  // Import database from a file
  Future<void> importDatabase(File sourceFile) async {
    // Close the current store
    store.close();
    
    // Copy the imported file to the database location
    final targetFile = File(p.join(dbPath, 'data.mdb'));
    await sourceFile.copy(targetFile.path);
    
    // Reopen the store
    final newStore = await openStore(directory: dbPath);
    store = newStore;
    eventLogBox = store.box<EventLog>();
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

    // static Future<DateTime?> getLastMedIntake() async {
    //   final lastIntake = await isar.eventLogs
    //       .filter()
    //       .sortByTimestampDesc()
    //       .findFirst();
    //   return lastIntake?.timestamp;
    // }
  }

  Future<void> deleteEvent(int id) async {
    eventLogBox.remove(id);
  }
}
