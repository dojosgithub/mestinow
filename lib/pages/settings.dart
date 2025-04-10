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

  late double _intervalHours;

  @override
  void initState() {
    _intervalHours = 3.0;
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final interval = prefs.getDouble(_intervalKey) ?? 3.0;

    setState(() {
      _intervalHours = interval;
    });
  }

  Future<void> _saveInterval(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_intervalKey, hours);
    setState(() {
      _intervalHours = hours;
    });
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
          ],
        ),
      ),
    );
  }
}
