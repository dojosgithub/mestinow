import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/medication_search_bar.dart';
import '../models/medication.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  List<Medication> _filteredMedications = Medication.medications;

  void _filterMedications(String query) {
    setState(() {
      _filteredMedications =
          Medication.medications.where((med) {
            return med.name.toLowerCase().contains(query.toLowerCase()) ||
                med.examples.any(
                  (example) =>
                      example.toLowerCase().contains(query.toLowerCase()),
                ) ||
                med.category.toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(
      'https://myasthenia.org/living-with-mg/mg-emergency-preparedness/cautionary-drugs/',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Color _getSeverityColor(MedicationSeverity severity) {
    switch (severity) {
      case MedicationSeverity.high:
        return Colors.red;
      case MedicationSeverity.medium:
        return Colors.orange;
      case MedicationSeverity.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.mgCautionaryMedications),
            pinned: true,
            floating: false,
          ),
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importantInformation,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.cautionaryMedicationsInfo),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _launchUrl,
                            icon: const Icon(Icons.open_in_new),
                            label: Text(l10n.visitMGFAWebsite),
                          ),
                        ),
                        const SizedBox(width: 16),
                        QrImageView(
                          data:
                              'https://myasthenia.org/living-with-mg/mg-emergency-preparedness/cautionary-drugs/',
                          version: QrVersions.auto,
                          size: 100.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          MedicationSearchBar(onSearchChanged: _filterMedications),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final medication = _filteredMedications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Container(
                    width: 4,
                    color: _getSeverityColor(medication.severity),
                  ),
                  title: Text(medication.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.category,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.examples.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.warning,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: _filteredMedications.length),
          ),
        ],
      ),
    );
  }
}
