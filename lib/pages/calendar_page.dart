import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../models/event_log.dart';
import '../services/database_service.dart';
import '../models/event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DatabaseService db;
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  late List<EventLog> _events = [];
  late AppLocalizations l10n;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);

    // Scroll to today's position after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      db = Provider.of<DatabaseService>(context);
      _loadEvents(); // Now safe to call
      _isInitialized = true;
    }
    l10n = AppLocalizations.of(context)!;
  }

  void _scrollToSelectedDate() {
    // Calculate position based on day of month (assuming each item width is 68.0 - 60 + 8 margin)
    final double itemWidth = 68.0;
    final double offset = (_selectedDate.day - 1) * itemWidth;

    // Animate to the position
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _loadEvents() async {
    // Load events for selected date
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final events = await db.getEventsForDateRange(startOfDay, endOfDay);

      setState(() {
        _events = events;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showTimePicker(EventLog event) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(event.timestamp),
    );

    if (time != null) {
      final newDateTime = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
        time.hour,
        time.minute,
      );

      await _updateEventTime(event, newDateTime);
    }
  }

  Future<void> _updateEventTime(EventLog event, DateTime newTime) async {
    try {
      await db.updateEventTime(event.id, newTime);
      await _loadEvents();
    } catch (e) {
      print("Error updating event time: $e");
    }
  }

  void _confirmDelete(EventLog event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.calendar_delete),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await db.deleteEvent(
        event.id,
      ); // Make sure this exists in your database service
      await _loadEvents();
    }
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_displayedMonth),
            style: TextStyle(
              fontSize:
                  18 / min(2.0, MediaQuery.of(context).textScaler.scale(1.0)),
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final date = firstDayOfMonth.add(Duration(days: index));
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _loadEvents();
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkPrimary,
                      fontSize:
                          14 /
                          min(
                            2.0,
                            MediaQuery.of(context).textScaler.scale(1.0),
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkPrimary,
                      fontSize:
                          18 /
                          min(
                            2.0,
                            MediaQuery.of(context).textScaler.scale(1.0),
                          ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [..._buildSymptomEvents()],
      ),
    );
  }

  List<Widget> _buildSymptomEvents() {
    return _events.map((event) {
      final displayableEvent = Event.findByCode(event.eventType);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading:
              displayableEvent != null
                  ? Image.asset(
                    displayableEvent.icon,
                    width: 24,
                    height: 24,
                    color: AppColors.primary,
                  )
                  : Icon(Icons.warning_amber_rounded, color: AppColors.primary),
          title: Text(
            displayableEvent?.getDisplayName(l10n) ?? event.eventType,
          ),
          subtitle: Text('${DateFormat('h:mm a').format(event.timestamp)} '),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  await _showTimePicker(event);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(event),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildDaySelector(),
          const Divider(),
          _buildEventsList(),
        ],
      ),
    );
  }
}
