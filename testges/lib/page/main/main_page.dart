import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/daily_course_provider.dart';

class MainPage extends ConsumerStatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
    _loadDailyCourses();
  }

  Future<void> _loadDailyCourses() async {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      await ref.read(dailyCourseProvider.notifier).loadDailyCourses(token);
    }
  }

  void _logout() {
    ref.read(authenticationProvider.notifier).state = null;
    Navigator.of(context).pushReplacementNamed('/login'); // Assuming you have a login route
  }

  @override
  Widget build(BuildContext context) {
    final dailyCourses = ref.watch(dailyCourseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Vos Cours'),
        backgroundColor: Colors.yellow[700],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Se déconnecter'),
                    ],
                  ),
                ),
              ];
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: dailyCourses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: dailyCourses.length,
        itemBuilder: (context, index) {
          final course = dailyCourses[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              leading: Icon(Icons.book, color: Colors.yellow[700]),
              title: Text(course.subjectName),
              subtitle: Text(
                  '${course.teacherFirstName} ${course.teacherLastName}\n${DateFormat.Hm().format(course.dateStart)} - ${DateFormat.Hm().format(course.dateEnd)}'),
              trailing: course.studentIsPresent
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.check_circle_outline, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
