import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class SymptomPreferencesPage extends StatefulWidget {
  @override
  _SymptomPreferencesPageState createState() => _SymptomPreferencesPageState();
}

class _SymptomPreferencesPageState extends State<SymptomPreferencesPage> {
  List<String> selectedCodes = [];
  final List<Event> allSymptoms = Event.getSymptoms();
  SharedPreferences? _prefs;

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              content: Text(l10n.symptomLimitMessage), // Add to .arb
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
                    Image.asset(symptom.icon, width: 32, height: 32),
                    const SizedBox(width: 12),
                    Expanded(child: Text(symptom.getDisplayName(l10n))),
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
