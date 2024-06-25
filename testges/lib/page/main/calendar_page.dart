import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/subjects_hour_provider.dart';
import '../../Model/subjects_hour.dart';

class CalendarPage extends ConsumerStatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      await ref.read(subjectsHourProvider.notifier).loadSubjectsHour(
        token,
        _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1)).toIso8601String(),
        _focusedDay.add(Duration(days: 7 - _focusedDay.weekday)).toIso8601String(),
      );
    }
  }

  List<Appointment> _getAppointmentsForWeek() {
    final subjectsHours = ref.watch(subjectsHourProvider);
    final appointments = subjectsHours
        .map((subjectHour) => Appointment(
      startTime: subjectHour.dateStart,
      endTime: subjectHour.dateEnd,
      subject: subjectHour.subject.name,
      //color: Colors.yellow[700],
      notes: '${subjectHour.subject.teacher.firstname} ${subjectHour.subject.teacher.lastname}\n Salle: ${subjectHour.room}',
    ))
        .toList();
    return appointments;
  }

  void _changeWeek(int days) async {
    setState(() {
      _focusedDay = _focusedDay.add(Duration(days: days));
    });
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _getAppointmentsForWeek();

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Calendar'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => _changeWeek(-7),
                ),
                Text(
                  'Week of ${DateFormat('MMMM dd, yyyy').format(_focusedDay.subtract(Duration(days: _focusedDay.weekday - 1)))}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => _changeWeek(7),
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.week,
              dataSource: MeetingDataSource(appointments),
              initialDisplayDate: _focusedDay,
              todayHighlightColor: Colors.red,
              timeSlotViewSettings: TimeSlotViewSettings(
                timeIntervalHeight: 60,
                startHour: 0,
                endHour: 24,
                timeFormat: 'HH:mm',
                timeInterval: Duration(minutes: 30),
              ),
              appointmentBuilder: (context, details) {
                final appointment = details.appointments.first;
                return Container(
                  decoration: BoxDecoration(
                    color: appointment.color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      appointment.subject,
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
