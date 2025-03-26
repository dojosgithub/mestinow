import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:lit_relative_date_time/lit_relative_date_time.dart';
import '../theme/colors.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  static const int totalSeconds = 3 * 60 * 60;
  static const String _timestampKey = 'last_button_press_time';
  late int remainingSeconds;
  late int? lastButtonPressTime;
  Timer? timer;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

  Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
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

    await notificationsPlugin.zonedSchedule(
      0,
      'Medication Reminder',
      'It\'s time to take your Mestinon.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          importance: Importance.max,
          priority: Priority.high,
          channelShowBadge: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
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

    lastButtonPressTime =
        prefs.getInt(_timestampKey) ??
        DateTime.parse('2025-03-25 15:45:00').millisecondsSinceEpoch;
    lastButtonPressTime =
        DateTime.parse('2025-03-25 18:10:00').millisecondsSinceEpoch;
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
    return Color(0xff5CBE9D);
    // minutes > 0 ? Color(0xff5CBE9D) : AppColors.error,// Color(0xff5CBE9D),
  }

  @override
  Widget build(BuildContext context) {
    RelativeDateFormat relativeDateFormat = RelativeDateFormat(
      Localizations.localeOf(context),
    );
    int minutes = remainingSeconds ~/ 60;
    final lastDoseDateTime = DateTime.fromMillisecondsSinceEpoch(
      lastButtonPressTime!,
    );
    final nextDoseDateTime = lastDoseDateTime.add(
      Duration(seconds: totalSeconds),
    );
    final relativeNextDose = relativeDateFormat.format(
      RelativeDateTime(dateTime: DateTime.now(), other: nextDoseDateTime),
    );
    Color frontColor = _getTimeBasedFrontColor(minutes);
    Color backColor = _getTimeBasedBackColor(minutes);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Spacer(),
          Container(
            // lower panel
            height: 534,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: backColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Last dose: ${relativeDateFormat.format(RelativeDateTime(dateTime: DateTime.now(), other: lastDoseDateTime))} at ${_formatTime(lastDoseDateTime)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                _buildCircularPercentIndicator(frontColor, relativeNextDose),
                SizedBox(height: 50),
                _buildTakeMestinonButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(children: [Text('Status')]);
  }

  Widget _buildCircularPercentIndicator(leftColor, relativeNextDose) {
    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 13.0,
      circularStrokeCap: CircularStrokeCap.round,
      percent: remainingSeconds <= 0 ? 0.0 : remainingSeconds / totalSeconds,
      center: Text(
        "Next dose\n$relativeNextDose",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // progressColor: Color(0xffe66912),
      progressColor: leftColor,
    );
  }

  Widget _buildTakeMestinonButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.darkPrimary,
        borderRadius: BorderRadius.circular(10),
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
          'Take early',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            fontSize: 21,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
