import 'package:flutter/material.dart';
import '../widgets/medication_list.dart';

class MedicationsPage extends StatelessWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MG Cautionary Medications')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Important Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This list contains medications that may affect Myasthenia Gravis (MG) symptoms. '
                'Always consult with your healthcare provider before starting or stopping any medication.',
              ),
              const SizedBox(height: 24),
              const SizedBox(
                height: 600, // Adjust height as needed
                child: MedicationList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
