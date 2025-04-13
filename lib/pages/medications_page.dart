import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/medication_list.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://myasthenia.org/living-with-mg/mg-emergency-preparedness/cautionary-drugs/');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MG Cautionary Medications')),
      body: Column(
        children: [
          Card(
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
          Expanded(
            child: const MedicationList(),
          ),
        ],
      ),
    );
  }
}
