import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../objectbox.g.dart';
import '../models/event_log.dart';
import '../models/custom_symptom.dart';
import 'dart:io';
import 'package:intl/intl.dart';

// import 'package:objectbox/objectbox.dart';

class DatabaseService {
  late Store store;
  late Box<EventLog> eventLogBox;
  late Box<CustomSymptom> customSymptomBox;
  late final String dbPath;
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  DatabaseService._create(this.store, this.dbPath) {
    eventLogBox = store.box<EventLog>();
    customSymptomBox = store.box<CustomSymptom>();
  }

  static Future<DatabaseService> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbDirectory = p.join(dir.path, "mestinow.db");
    final store = await openStore(
      directory: dbDirectory,
    ); //ObjectBox.create(getObjectBoxModel(), directory: dir.path);
    return DatabaseService._create(store, dbDirectory);
  }

  // Export data to CSV format
  Future<File> exportToCSV() async {
    // Get all events
    final query =
        eventLogBox
            .query()
            .order(EventLog_.timestamp, flags: Order.descending)
            .build();
    final events = query.find();
    query.close();

    // Create CSV content
    final csvContent = StringBuffer();

    // Add header
    csvContent.writeln('Timestamp,Event Type');

    // Add data rows
    for (final event in events) {
      final timestamp = _dateFormat.format(event.timestamp);
      final eventType = event.eventType;
      csvContent.writeln('$timestamp,$eventType');
    }

    // Save to file
    final dir = await getApplicationDocumentsDirectory();
    final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
    final csvPath = p.join(dir.path, 'mestinow_data_$dateStr.csv');
    final file = File(csvPath);
    await file.writeAsString(csvContent.toString());

    return file;
  }

  // Backup database to a file
  Future<File> backupDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final exportPath = p.join(dir.path, 'mestinow_export.db');

    // Copy the database file
    final sourceFile = File(p.join(dbPath, 'data.mdb'));
    final targetFile = File(exportPath);

    await sourceFile.copy(targetFile.path);
    return targetFile;
  }

  // Restore database from a file
  Future<void> restoreDatabase(File sourceFile) async {
    // Close the current store
    store.close();

    // Copy the imported file to the database location
    final targetFile = File(p.join(dbPath, 'data.mdb'));
    await sourceFile.copy(targetFile.path);

    // Reopen the store
    final newStore = await openStore(directory: dbPath);
    store = newStore;
    eventLogBox = store.box<EventLog>();
    customSymptomBox = store.box<CustomSymptom>();
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

  // Custom symptom methods
  Future<CustomSymptom> createCustomSymptom(String name) async {
    final symptom = CustomSymptom(
      name: name,
    );
    customSymptomBox.put(symptom);
    return symptom;
  }

  Future<List<CustomSymptom>> getAllCustomSymptoms() async {
    return customSymptomBox.getAll();
  }

  Future<void> deleteCustomSymptom(int id) async {
    customSymptomBox.remove(id);
  }
}
