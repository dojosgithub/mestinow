import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../theme/colors.dart';
import '../services/database_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:mestinow/pages/symptom_preferences_page.dart';
import 'package:mestinow/pages/about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _intervalKey = 'mestinon_interval_hours';
  static const String _dailyLimitKey = 'mestinon_daily_limit';

  late double _intervalHours;
  late int _dailyLimit;
  late DatabaseService _db;
  late AppLocalizations l10n;

  @override
  void initState() {
    _intervalHours = 3.0;
    _dailyLimit = 6;
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _db = Provider.of<DatabaseService>(context);
    l10n = AppLocalizations.of(context)!;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final interval = prefs.getDouble(_intervalKey) ?? 3.0;
    final limit = prefs.getInt(_dailyLimitKey) ?? 6;

    setState(() {
      _intervalHours = interval;
      _dailyLimit = limit;
    });
  }

  Future<void> _saveInterval(double hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_intervalKey, hours);
    setState(() {
      _intervalHours = hours;
    });
  }

  Future<void> _saveDailyLimit(int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyLimitKey, limit);
    setState(() {
      _dailyLimit = limit;
    });
  }

  Future<void> _exportData() async {
    try {
      final exportFile = await _db.exportToCSV();

      // Show a dialog with options to share or save
      if (mounted) {
        final result = await showDialog<String>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text(l10n.exportData),
                content: Text(l10n.exportDataDescription),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('share'),
                    child: Text(l10n.share),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('save'),
                    child: Text(l10n.save),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('cancel'),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
        );

        if (result == 'share') {
          final box = context.findRenderObject() as RenderBox;
          await Share.shareXFiles(
            [XFile(exportFile.path)],
            text: l10n.exportData,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          );
        } else if (result == 'save') {
          // Get the directory for saving the file
          final directory = await FilePicker.platform.getDirectoryPath();
          final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
          final savePath = p.join(directory!, 'mestinow_backup_$dateStr.db');

          // Copy the export file to a known location
          await exportFile.copy(savePath);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.exportedTo}: $savePath')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.errorExporting}: $e')));
      }
    }
  }

  Future<void> _backupDatabase() async {
    try {
      final exportFile = await _db.backupDatabase();

      // Show a dialog with options to share or save
      if (mounted) {
        final result = await showDialog<String>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text(l10n.backup),
                content: Text(l10n.backupDescription),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('share'),
                    child: Text(l10n.share),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('save'),
                    child: Text(l10n.save),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop('cancel'),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
        );

        if (result == 'share') {
          final box = context.findRenderObject() as RenderBox;
          await Share.shareXFiles(
            [XFile(exportFile.path)],
            text: l10n.backup,
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
          );
        } else if (result == 'save') {
          // Get the directory for saving the file
          final directory = await FilePicker.platform.getDirectoryPath();
          final dateStr = DateFormat('yyyy_MM_dd').format(DateTime.now());
          final savePath = p.join(directory!, 'mestinow_backup_$dateStr.db');

          // Copy the export file to a known location
          await exportFile.copy(savePath);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${l10n.savedTo}: $savePath')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.errorBackup}: $e')));
      }
    }
  }

  Future<void> _restoreDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final result = await FilePicker.platform.pickFiles(
        initialDirectory: directory.path,
        type: FileType.any,
        dialogTitle: l10n.selectBackup,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);

        // Verify the file is a valid database backup
        if (!await file.exists()) {
          throw Exception(l10n.fileDoesNotExist);
        }

        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text(l10n.confirm),
                content: Text(l10n.confirmOverwrite),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Import'),
                  ),
                ],
              ),
        );

        if (confirm == true) {
          await _db.restoreDatabase(file);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.backupSuccess)));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.backupFailure)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: l10n.medicationInterval,
                child: Row(
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
              ),
              _buildSection(
                title: l10n.dailyDoseLimit,
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _dailyLimit.toDouble(),
                        min: 2,
                        max: 8,
                        divisions: 6,
                        label: '$_dailyLimit ${l10n.doses}',
                        onChanged: (value) => _saveDailyLimit(value.toInt()),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$_dailyLimit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSection(
                title: l10n.symptomPreferences,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.symptomPreferences,
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SymptomPreferencesPage()),
                    );
                  },
                ),
              ),
              _buildSection(
                title: l10n.dataManagement,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.upload,
                            label: l10n.backup,
                            onPressed: _backupDatabase,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.download,
                            label: l10n.restore,
                            onPressed: _restoreDatabase,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children:[ Expanded( child: _buildActionButton(
                        icon: Icons.backup,
                        label: l10n.exportData,
                        onPressed: _exportData,
                      ),)]
                    ),
                  ],
                ),
              ),
              _buildSection(
                title: l10n.about,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.aboutApp, style: const TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lighterPrimary,
        foregroundColor: AppColors.darkPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
