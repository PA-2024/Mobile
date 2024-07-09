import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/daily_course_provider.dart';

class MainPage extends ConsumerStatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _loadDailyCourses();
    _controller.forward();
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

  void _scanQRCode() {
    // Action to scan QR code
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyCourses = ref.watch(dailyCourseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('GeSign'),
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
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Voici vos cours pour aujourd\'hui:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: dailyCourses.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: dailyCourses.length,
                itemBuilder: (context, index) {
                  final course = dailyCourses[index];
                  return SlideTransition(
                    position: _animation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          // Action to show course details and sign attendance
                          _scanQRCode();
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.yellow[700],
                              child: Icon(Icons.book, color: Colors.white),
                            ),
                            title: Text(
                              course.subjectName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            subtitle: Text(
                              '${course.teacherFirstName} ${course.teacherLastName}\n${DateFormat.Hm().format(course.dateStart)} - ${DateFormat.Hm().format(course.dateEnd)}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            trailing: course.studentIsPresent
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : Icon(Icons.check_circle_outline, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        child: Icon(Icons.qr_code_scanner),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
