import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _intervalKey = 'mestinon_interval_hours';
  static const String _timestampKey = 'last_button_press_time';

  late double _intervalHours;
  late DateTime _lastTakenTime;

  @override
  void initState() {
    _intervalHours = 3.0;
    _lastTakenTime = DateTime.now();
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final interval = prefs.getDouble(_intervalKey) ?? 3.0;
    final timestamp =
        prefs.getInt(_timestampKey) ?? DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _intervalHours = interval;
      _lastTakenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    });
  }

  Future<void> _saveInterval(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_intervalKey, hours);
    setState(() {
      _intervalHours = hours;
    });
  }

  Future<void> _saveLastTakenTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timestampKey, time.millisecondsSinceEpoch);
    setState(() {
      _lastTakenTime = time;
    });
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_lastTakenTime),
    );

    if (time != null) {
      final now = DateTime.now();
      final newDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      await _saveLastTakenTime(newDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.medicationInterval,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _intervalHours,
                    min: 3,
                    max: 6,
                    divisions: 6,
                    label: '${_intervalHours.toStringAsFixed(1)} hours',
                    onChanged: (value) => _saveInterval(value),
                    activeColor: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${_intervalHours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              l10n.lastDoseTime,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _showTimePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_lastTakenTime.hour > 12 ? _lastTakenTime.hour - 12 : _lastTakenTime.hour}:'
                      '${_lastTakenTime.minute.toString().padLeft(2, '0')} '
                      '${_lastTakenTime.hour >= 12 ? 'PM' : 'AM'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
