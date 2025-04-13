import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationList extends StatefulWidget {
  const MedicationList({super.key});

  @override
  State<MedicationList> createState() => _MedicationListState();
}

class _MedicationListState extends State<MedicationList> {
  final TextEditingController _searchController = TextEditingController();
  List<Medication> _filteredMedications = Medication.medications;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterMedications);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMedications() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedications =
          Medication.medications.where((med) {
            return med.name.toLowerCase().contains(query) ||
                med.examples.any(
                  (example) => example.toLowerCase().contains(query),
                ) ||
                med.category.toLowerCase().contains(query);
          }).toList();
    });
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search medications...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMedications.length,
            itemBuilder: (context, index) {
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
            },
          ),
        ),
      ],
    );
  }
}
