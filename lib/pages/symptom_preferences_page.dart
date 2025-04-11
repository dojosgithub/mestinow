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

  @override
  void initState() {
    super.initState();
    _initPrefs();
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.symptomPreferences)),
      body: ListView(
        children: allSymptoms.map((symptom) {
          final code = symptom.code;
          return CheckboxListTile(
            title: Row(
              children:[
                Image.asset(
                  symptom.icon, 
                  width: 32,
                  height: 32,
                  ),
                const SizedBox(width: 12),
                Expanded(child: Text(symptom.getDisplayName(l10n))),
              ],
            ),
            value: selectedCodes.contains(code),
            onChanged: (selected) => _toggleSymptom(code, selected),
          );
        }).toList(),
      ),
    );
  }
}

