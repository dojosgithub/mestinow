import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:relative_time/relative_time.dart';
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

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late DatabaseService db;
  late int totalSeconds = 3 * 60 * 60;
  static const String _timestampKey = 'last_button_press_time';
  static const String _intervalKey = 'mestinon_interval_hours';
  late int remainingSeconds;
  late int? lastButtonPressTime;
  late List<EventLog> _events = [];
  final String _fontFamily = GoogleFonts.roboto().fontFamily!;
  Timer? timer;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Add symptom data
  final List<Map<String, String>> symptoms = [
    {'icon': 'assets/icons/ptosis.png', 'label': 'Ptosis'},
    {'icon': 'assets/icons/vision.png', 'label': 'Vision'},
    {'icon': 'assets/icons/weakness.png', 'label': 'Weakness'},
    {'icon': 'assets/icons/neck.png', 'label': 'Neck'},
    {'icon': 'assets/icons/breathing.png', 'label': 'Breathing'},
    {'icon': 'assets/icons/walking.png', 'label': 'Walking'},
  ];

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

  @override
  void initState() {
    remainingSeconds = totalSeconds;
    lastButtonPressTime = 0;
    super.initState();
    _loadSavedTime();
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
  }

  Future<void> _saveMedIntake() async {
    // final prefs = await SharedPreferences.getInstance();
    // final intervalHours = prefs.getDouble(_intervalKey) ?? 3.0;

    await db.logEvent(EventType.medMestinon.name);
    // await _saveButtonPressTime();
    // setState(() {
    //   remainingSeconds = totalSeconds;
    // });
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

  Future<void> _loadSavedTime() async {
    await notificationsPlugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();

    totalSeconds = ((prefs.getDouble(_intervalKey) ?? 3) * 60 * 60).ceil();

    lastButtonPressTime =
        prefs.getInt(_timestampKey) ??
        DateTime.parse('2025-03-25 15:45:00').millisecondsSinceEpoch;

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
    final prefs = await SharedPreferences.getInstance();
    lastButtonPressTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_timestampKey, lastButtonPressTime!);
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
  Widget _buildSymptomGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisExtent: 85.0,
          mainAxisSpacing: 8,
          // childAspectRatio: 1.5,
        ),
        itemCount: symptoms.length,
        itemBuilder: (context, index) {
          final symptom = symptoms[index];
          return SymptomButton(
            iconPath: symptom['icon']!,
            label: symptom['label']!,
            onPressed: () {
              setState(() {
                final label = symptom['label']!;
                db.logEvent(label);
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    db = Provider.of<DatabaseService>(context);
    _loadEvents();
    final l10n = AppLocalizations.of(context)!;

    int minutes = remainingSeconds ~/ 60;
    final lastDoseDateTime = DateTime.fromMillisecondsSinceEpoch(
      lastButtonPressTime!,
    );
    final nextDoseDateTime = lastDoseDateTime.add(
      Duration(seconds: totalSeconds),
    );
    final relativeNextDose = RelativeTime(
      context,
      timeUnits: [TimeUnit.day, TimeUnit.hour, TimeUnit.minute],
    ).format(nextDoseDateTime);
    final relativeLastDose = RelativeTime(
      context,
      timeUnits: [TimeUnit.day, TimeUnit.hour, TimeUnit.minute],
    ).format(lastDoseDateTime);

    Color frontColor = _getTimeBasedFrontColor(minutes);
    Color backColor = _getTimeBasedBackColor(minutes);
    final screenWidth = MediaQuery.of(context).size.width;

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
              child: const BrandText(
                color: Colors.white,
              ),
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
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ).then(
                  (_) => _loadSavedTime(),
                ); // Reload settings when returning
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(l10n.calendar),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 350,
            ), // Leave space for bottom panel
            child: Column(
              children: [
                _buildSymptomGrid(),

                // Centered "Today" with underline
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text('Today', style: TextStyle(fontSize: 12)),
                      ),
                      SizedBox(height: 2),
                      Divider(
                        thickness: 1,
                        color: AppColors.lightGrey,
                        indent: 0,
                        endIndent: 0, // light underline
                      ),
                    ],
                  ),
                ),

                // Scrollable List
                Expanded(
                  child: ListView.separated(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      String formattedTime =
                          '${DateFormat('h:mm a').format(event.timestamp)} '; // e.g., 5:30 PM
                      return ListTile(
                        title: Text(
                          '$formattedTime - ${event.eventType == 'medMestinon' ? 'Mestinon' : event.eventType}',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                    separatorBuilder:
                        (context, index) => Divider(
                          color: AppColors.lightGrey,
                          thickness: 1,
                          height: 0, // tight spacing between items
                          indent: 16,
                          endIndent: 16,
                        ),
                  ),
                ), // Makes the ListView take up the remaining space
              ],
            ),
          ),
          // Fixed bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              // lower panel
              height: screenWidth * 0.75,
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
                  SizedBox(height: screenWidth * 0.05),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      '${l10n.lastDose}: $relativeLastDose ${l10n.at} ${_formatTime(lastDoseDateTime)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: AppColors.darkPrimary,
                        fontFamily: _fontFamily,
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildCircularPercentIndicator(
                        frontColor,
                        relativeNextDose,
                        screenWidth,
                        l10n,
                      ),
                      // SizedBox(height: 50),
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
    l10n,
  ) {
    return CircularPercentIndicator(
      radius: screenWidth * 0.25,
      lineWidth: 13.0,
      circularStrokeCap: CircularStrokeCap.round,
      percent:
          remainingSeconds <= 0
              ? 0.0
              : min(remainingSeconds, totalSeconds) / totalSeconds,
      center: Text(
        "${l10n.nextDose}\n$relativeNextDose",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: _fontFamily,
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
        // backgroundColor: Color(0xff016367),
        onPressed: () async {
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
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
