import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/subjects_hour_provider.dart';


class CalendarPage extends ConsumerStatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      final startDate = _focusedDay.subtract(Duration(days: 365));
      final endDate = _focusedDay.add(Duration(days: 365));
      print('Loading events from $startDate to $endDate'); // Debugging log
      await ref.read(subjectsHourProvider.notifier).loadSubjectsHour(
        token,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      );
    }
  }

  List<Appointment> _getAppointmentsForDay() {
    final subjectsHours = ref.watch(subjectsHourProvider);
    return subjectsHours
        .where((subjectHour) => isSameDay(subjectHour.dateStart, _selectedDay))
        .map((subjectHour) => Appointment(
      startTime: subjectHour.dateStart,
      endTime: subjectHour.dateEnd,
      subject: subjectHour.subject.name,
      color: Colors.yellow[700] ?? Colors.yellow,
      notes: '${subjectHour.subject.teacher.firstname} ${subjectHour.subject.teacher.lastname}\nSalle: ${subjectHour.room}',
      id: subjectHour.id,
      location: subjectHour.room,
      resourceIds: [subjectHour.building.name, subjectHour.building.city, subjectHour.building.address],
    ))
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _getAppointmentsForDay();
    print('Appointments for selected day: $appointments'); // Debugging log

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendrier'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[200]!, Colors.yellow[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                locale: 'fr_FR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _loadEvents();
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.yellow[700],
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                ),
              ),
            ),
            Expanded(
              child: appointments.isEmpty
                  ? Center(
                child: FadeTransition(
                  opacity: _animation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_satisfied_alt, color: Colors.orange, size: 80),
                      SizedBox(height: 16),
                      Text(
                        "Pas de cours aujourd'hui!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.yellow[700],
                          child: Icon(Icons.book, color: Colors.white),
                        ),
                        title: Text(
                          appointment.subject,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        subtitle: Text(
                          '${appointment.notes}\nHoraire: ${DateFormat('HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          _showCourseDetailsDialog(context, appointment);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseDetailsDialog(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appointment.subject),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professeur: ${appointment.notes?.split('\n')[0]}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Salle: ${appointment.location}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Bâtiment: ${appointment.resourceIds?[0] ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Adresse: ${appointment.resourceIds?[1] ?? ''} - ${appointment.resourceIds?[2] ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Horaire: ${DateFormat('HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
