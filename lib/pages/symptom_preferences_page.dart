import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/database_service.dart';
import '../theme/colors.dart';

class SymptomPreferencesPage extends StatefulWidget {
  @override
  _SymptomPreferencesPageState createState() => _SymptomPreferencesPageState();
}

class _SymptomPreferencesPageState extends State<SymptomPreferencesPage> {
  List<String> selectedCodes = [];
  List<Event> allSymptoms = [];
  SharedPreferences? _prefs;
  late DatabaseService _db;

  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();

    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!_showBackToTopButton) {
          setState(() => _showBackToTopButton = true);
        }
      } else {
        if (_showBackToTopButton) {
          setState(() => _showBackToTopButton = false);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _db = Provider.of<DatabaseService>(context);
    _loadCustomSymptoms();
  }

  Future<void> _loadCustomSymptoms() async {
    final customSymptoms = await _db.getAllCustomSymptoms();
    setState(() {
      allSymptoms = [
        ...Event.getSymptoms(),
        ...customSymptoms.map(
          (s) =>
              Event(code: s.name, icon: 'assets/icons/custom.png', type: 'sym'),
        ),
      ];
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCodes = _prefs?.getStringList('preferred_symptoms') ?? [];
    });
  }

  void _toggleSymptom(String code, bool? selected) {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      if (selected == true) {
        if (selectedCodes.length < 7 && !selectedCodes.contains(code)) {
          selectedCodes.add(code);
        } else if (selectedCodes.length >= 7) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.symptomLimitMessage),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        selectedCodes.remove(code);
      }
      _prefs?.setStringList('preferred_symptoms', selectedCodes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Event> sortedSymptoms = [...allSymptoms]..sort((a, b) {
      final aSelected = selectedCodes.contains(a.code);
      final bSelected = selectedCodes.contains(b.code);

      if (aSelected != bSelected) {
        return (bSelected ? 1 : 0) - (aSelected ? 1 : 0);
      }

      return a.getDisplayName(l10n).compareTo(b.getDisplayName(l10n));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.symptomPreferences),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightGrey,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        controller: _scrollController,
        children:
            sortedSymptoms.map((symptom) {
              final code = symptom.code;
              return CheckboxListTile(
                title: Row(
                  children: [
                    Image.asset(
                      symptom.icon,
                      color: AppColors.darkPrimary,
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Text(symptom.getDisplayName(l10n))),
                          if (selectedCodes.contains(code))
                            Row(
                              children: [
                                const Icon(
                                  Icons.speed,
                                  size: 16,
                                  color: AppColors.darkPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.quickButton,
                                  style: const TextStyle(
                                    color: AppColors.darkPrimary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                value: selectedCodes.contains(code),
                onChanged: (selected) => _toggleSymptom(code, selected),
              );
            }).toList(),
      ),
      floatingActionButton:
          _showBackToTopButton
              ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
                tooltip: 'l10n.backToTop',
              )
              : null,
    );
  }
}
