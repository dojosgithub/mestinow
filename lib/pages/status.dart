import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../pages/settings.dart';
import '../widgets/symptom_button.dart';
import '../widgets/brand_text.dart';
import '../services/database_service.dart';
import '../models/event_log.dart';
import '../pages/calendar_page.dart';
import '../pages/onboarding/tour_page.dart';
import 'package:mestinow/models/event.dart';
import '../pages/medications_page.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late DatabaseService db;
  late int totalSeconds = 3 * 60 * 60;
  static const String _intervalKey = 'mestinon_interval_hours';
  static const String _dailyLimitKey = 'mestinon_daily_limit';
  late int remainingSeconds;
  late int? lastButtonPressTime;
  late List<EventLog> _events = [];
  late int _dailyLimit = 6;
  final String _fontFamily = GoogleFonts.roboto().fontFamily!;
  late double textScaleFactor = 1.0;
  Timer? timer;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Use the Symptom model instead of hardcoded list
  final List<Event> symptoms = Event.getSymptoms();

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyLimit = prefs.getInt(_dailyLimitKey) ?? 6;
    });
  }

  Future<int> _getTodayDoseCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final events = await db.getEventsForDateRange(startOfDay, endOfDay);
    return events.where((e) => e.eventType == EventType.medMestinon.name).length;
  }

  @override
  void initState() {
    remainingSeconds = totalSeconds;
    lastButtonPressTime = 0;
    super.initState();
    timer = Timer.periodic(Duration(seconds: 20), (timer) {
      setState(() {
        if (lastButtonPressTime != null) {
          final elapsedSeconds =
              (DateTime.now().millisecondsSinceEpoch - lastButtonPressTime!) ~/
              1000;
          remainingSeconds = totalSeconds - elapsedSeconds;
        }
      });
    });
    initializeNotifications();
    _loadSettings();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedTime();
    db = Provider.of<DatabaseService>(context);
    _loadEvents();
    textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);
  }

  Future<List<Event>> _loadSymptomsToDisplay() async {
    final prefs = await SharedPreferences.getInstance();
    final preferredCodes = prefs.getStringList('preferred_symptoms') ?? [];

    final allSymptoms = Event.getSymptoms();

    final preferredSymptoms = allSymptoms
        .where((event) => preferredCodes.contains(event.code))
        .toList();

    final fallbackSymptoms = allSymptoms
        .where((event) => !preferredCodes.contains(event.code))
        .take(7 - preferredSymptoms.length)
        .toList();

    return [...preferredSymptoms, ...fallbackSymptoms];
  }

  Future<void> _loadEvents() async {
    // Load events for today
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final events = await db.getEventsForDateRange(startOfDay, endOfDay);

      setState(() {
        _events = events;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveMedIntake() async {
    await db.logEvent(EventType.medMestinon.name);
    _loadEvents();
  }

  Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    print('initializeNotifications');
  }

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    print('onDidReceiveNotificationResponse');
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  void _showOtherNoteDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.enterNote),
            content: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.describeSymptom,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final note = _controller.text.trim();
                  if (note.isNotEmpty) {
                    await db.logEvent(note);
                    _loadEvents();
                  }
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
    );
  }

  Future<void> scheduleNextDoseNotification(DateTime scheduledTime) async {
    await notificationsPlugin.cancelAll(); // cancel previous notifications

    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }
    final fiveMinutesBefore = scheduledTime.subtract(Duration(minutes: 5));
    await doScheduleNextDoseNotification(
      fiveMinutesBefore,
      'It will soon be time to take your Medication.',
      0,
    );
    await doScheduleNextDoseNotification(
      scheduledTime,
      'It\'s time to take your Medication.',
      1,
    );
  }

  Future<void> doScheduleNextDoseNotification(
    DateTime scheduledTime,
    String message,
    int notificationId,
  ) async {
    await notificationsPlugin.zonedSchedule(
      notificationId,
      'Medication Reminder',
      message,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel2',
          'Medication Reminders',
          channelDescription: 'Medication AudioReminders',
          importance: Importance.max,
          priority: Priority.high,
          channelShowBadge: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('alert'),
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          sound: 'alert.mp3',
        ),
      ),
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<int?> getLastMedIntake() async {
    final event = await db.getLastMedIntake();
    return event?.timestamp.millisecondsSinceEpoch;
  }

  Future<void> _loadSavedTime() async {
    await notificationsPlugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();

    totalSeconds = ((prefs.getDouble(_intervalKey) ?? 3) * 60 * 60).ceil();

    lastButtonPressTime =
        await getLastMedIntake() ?? DateTime.now().millisecondsSinceEpoch;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (currentTime - lastButtonPressTime!) ~/ 1000;

    final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      lastButtonPressTime! + (totalSeconds * 1000),
    );
    scheduleNextDoseNotification(scheduledTime);

    lastButtonPressTime ??=
        DateTime.now()
            .add(Duration(seconds: -totalSeconds * 1000))
            .millisecondsSinceEpoch;
    setState(() {
      remainingSeconds = totalSeconds - elapsedSeconds;
    });
  }

  Future<void> _saveButtonPressTime() async {
    lastButtonPressTime = DateTime.now().millisecondsSinceEpoch;
    await _saveMedIntake();

    final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      lastButtonPressTime! + (totalSeconds * 1000),
    );
    scheduleNextDoseNotification(scheduledTime);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Color _getTimeBasedFrontColor(int minutes) {
    if (minutes > 60) return AppColors.invalid;
    if (minutes > 20) return AppColors.primary;
    return AppColors.warning;
  }

  Color _getTimeBasedBackColor(int minutes) {
    if (minutes < 1) return AppColors.error;
    return AppColors.lightPrimary;
  }

  // Add this widget to your build method, before the CircularPercentIndicator
  Widget _buildSymptomGrid(screenWidth, screenHeight, l10n) {
    return FutureBuilder<List<Event>>(
      future: _loadSymptomsToDisplay(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final limitedSymptoms = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 1,
              mainAxisExtent: screenHeight * 0.1,
              mainAxisSpacing: 8,
              // childAspectRatio: 1.5,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              if (index < 7) {
                final symptom = limitedSymptoms[index];
                return SymptomButton(
                  size: screenHeight * 0.06,
                  iconPath: symptom.icon,
                  label: symptom.getDisplayName(l10n),
                  onPressed: () {
                    setState(() {
                      db.logEvent(symptom.code);
                      _loadEvents();
                    });
                  },
                );
              } else {
                // 8th button is "Other"
                return SymptomButton(
                  size: screenHeight * 0.06,
                  iconPath: '',
                  label: l10n.other,
                  onPressed: () => _showOtherNoteDialog(context),
                );
              }
            },
          ),
        );
      },
    );
  }

  // Function to calculate responsive font size that accounts for text scaling
  double getResponsiveFontSize(double baseSize, double textScaleFactor) {
    // Adjust base size based on text scale factor
    // We'll cap the maximum scaling to 2.0 to prevent extreme sizes
    final adjustedScale = min(textScaleFactor, 2.0);
    return baseSize / adjustedScale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    int minutes = remainingSeconds ~/ 60;
    final lastDoseDateTime = DateTime.fromMillisecondsSinceEpoch(
      lastButtonPressTime!,
    );
    final nextDoseDateTime = lastDoseDateTime.add(
      Duration(seconds: totalSeconds),
    );
    final relativeNextDose = timeago.format(
      nextDoseDateTime,
      allowFromNow: true,
      locale: Localizations.localeOf(context).languageCode,
    );
    final relativeLastDose = timeago.format(
      lastDoseDateTime,
      allowFromNow: true,
      locale: Localizations.localeOf(context).languageCode,
    );

    Color frontColor = _getTimeBasedFrontColor(minutes);
    Color backColor = _getTimeBasedBackColor(minutes);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16),
          child: const BrandText(),
        ),
        leadingWidth: 180,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                color: AppColors.darkPrimary,
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: const BrandText(color: Colors.white),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(l10n.tour),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TourPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.settings),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                _loadSavedTime();
                _loadEvents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(l10n.calendar),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
                _loadSavedTime();
                _loadEvents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: Text(l10n.medications),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicationsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Main content column
          Padding(
            padding: EdgeInsets.only(
              bottom: min(
                screenWidth * 0.72,
                screenHeight * 0.5,
              ), // Match bottom panel height
            ),
            child: Column(
              children: [
                // Fixed symptom grid at the top
                _buildSymptomGrid(screenWidth, screenHeight, l10n),

                // Fixed "Today" text and divider
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 12 / min(2.0, textScaleFactor),
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Divider(
                        thickness: 1,
                        color: AppColors.lightGrey,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ],
                  ),
                ),

                // Scrollable ListView with proper constraints
                Expanded(
                  child: ListView.separated(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      final displayableEvent = Event.findByCode(
                        event.eventType,
                      );
                      String formattedTime =
                          '${DateFormat('h:mm a').format(event.timestamp)} ';
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          '$formattedTime - ${displayableEvent?.getDisplayName(l10n) ?? event.eventType}',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: getResponsiveFontSize(
                              screenHeight * 0.015,
                              textScaleFactor,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder:
                        (context, index) => Divider(
                          color: AppColors.lightGrey,
                          thickness: 1,
                          height: 0,
                          indent: 16,
                          endIndent: 16,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: min(screenWidth * 0.72, screenHeight * 0.5),
              width: screenWidth,
              decoration: BoxDecoration(
                color: backColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: screenWidth * 0.045),
                  Container(
                    width: screenWidth,
                    child: Text(
                      '${l10n.lastDose}: $relativeLastDose ${l10n.at} ${_formatTime(lastDoseDateTime)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(
                          screenWidth * 0.04,
                          textScaleFactor,
                        ),
                        color: AppColors.darkPrimary,
                        fontFamily: _fontFamily,
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.045),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildCircularPercentIndicator(
                        frontColor,
                        relativeNextDose,
                        screenWidth,
                        screenHeight,
                        l10n,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildTakeMestinonButton(l10n),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularPercentIndicator(
    leftColor,
    relativeNextDose,
    screenWidth,
    screenHeight,
    l10n,
  ) {
    return CircularPercentIndicator(
      radius: min(screenWidth * 0.25, screenHeight * 0.15),
      lineWidth: screenWidth * 0.02,
      circularStrokeCap: CircularStrokeCap.round,
      percent:
          remainingSeconds <= 0
              ? 0.0
              : min(remainingSeconds, totalSeconds) / totalSeconds,
      center: Container(
        width: screenWidth * 0.3,
        child: Text(
          "${l10n.nextDose}\n$relativeNextDose",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getResponsiveFontSize(
              min(screenWidth * 0.055, screenHeight * 0.03),
              textScaleFactor,
            ),
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: _fontFamily,
          ),
        ),
      ),
      progressColor: leftColor,
    );
  }

  Widget _buildTakeMestinonButton(l10n) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.darkPrimary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton(
        onPressed: () async {
          final todayDoses = await _getTodayDoseCount();
          if (todayDoses >= _dailyLimit) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.dailyDoseLimit}!'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
          await _saveButtonPressTime();
          setState(() {
            remainingSeconds = totalSeconds;
          });
        },
        child: Text(
          '+ ${l10n.logDoseNow}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: _fontFamily,
            fontSize: getResponsiveFontSize(14, textScaleFactor),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
