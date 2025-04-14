import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/medication_list.dart';
import '../models/medication.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://myasthenia.org/living-with-mg/mg-emergency-preparedness/cautionary-drugs/');
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('MG Cautionary Medications'),
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
                    const Text(
                      'Important Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This list contains medications that may affect Myasthenia Gravis (MG) symptoms. It is based on recommendations from the Myasthenia Gravis Foundation of America (MGFA). Always consult with your healthcare provider before starting or stopping any medication.',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _launchUrl,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Visit MGFA Website'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        QrImageView(
                          data: 'https://myasthenia.org/living-with-mg/mg-emergency-preparedness/cautionary-drugs/',
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          const MedicationList(),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final medication = Medication.medications[index];
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
              },
              childCount: Medication.medications.length,
            ),
          ),
        ],
      ),
    );
  }
}
