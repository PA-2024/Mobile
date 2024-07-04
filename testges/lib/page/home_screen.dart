import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/page/main/main_page.dart';
import 'package:testges/page/main/calendar_page.dart';
import 'package:testges/page/main/absence_page.dart';
import 'package:testges/page/main/qcm_page.dart';
import 'package:testges/service/provider/absence_provider.dart';
import 'package:testges/service/authentication_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    MainPage(),
    CalendarPage(),
    AbsencePage(),
    QcmPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = ref.read(authenticationProvider.notifier).state;
      if (token != null) {
        ref.read(absenceProvider.notifier).loadAttendanceSummary(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final absenceSummary = ref.watch(absenceProvider);
    final int totalMissed = absenceSummary['total_Missed'] ?? 0;

    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: 'Main',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 30),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.assignment_ind, size: 30),
                  if (totalMissed > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$totalMissed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Absence',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer, size: 30),
              label: 'QCM',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 10,
        ),
      ),
    );
  }
}
