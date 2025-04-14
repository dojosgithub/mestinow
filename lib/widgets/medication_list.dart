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
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchBarDelegate(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
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
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchBarDelegate({required this.child});

  @override
  double get minExtent => 80.0;
  @override
  double get maxExtent => 80.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
