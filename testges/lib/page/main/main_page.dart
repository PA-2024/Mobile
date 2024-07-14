import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/daily_course_provider.dart';
import '../../service/provider/presence_provider.dart';
import 'package:testges/page/main/QrScan.dart';

class MainPage extends ConsumerStatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late ConfettiController _confettiController;
  bool _isProcessing = false;

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
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
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
      body: Stack(
        children: [
          Container(
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
                              if (!course.studentIsPresent) {
                                _navigateToQRScanner(course.id);
                              }
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
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToQRScanner(null),
        child: Icon(Icons.qr_code_scanner),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _navigateToQRScanner(int? subjectHourId) async {
    final code = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScan(),
      ),
    );

    if (code != null && subjectHourId != null) {
      _handleQRCodeScan(code, subjectHourId);
    }
  }

  Future<void> _handleQRCodeScan(String code, int subjectHourId) async {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      final studentId = decodedToken['Student_Id'].toString();
      final message = "validate $subjectHourId $studentId $code";
      final url = 'wss://apigessignrecette-c5e974013fbd.herokuapp.com/ws';
      ref.read(presenceProvider.notifier).connectWebSocket(url);

      _showLoadingDialog(); // Show loading dialog

      ref.read(presenceProvider.notifier).sendMessage(message);
      ref.read(presenceProvider.notifier).messages.listen((message) async {
        Navigator.of(context).pop(); // Dismiss loading dialog

        if (message['action'] == 'VALIDATED') {
          _confettiController.play();
          await _updateCoursePresence(subjectHourId);
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pop(context); // Return to MainPage
          });
        } else if (message['action'] == 'ERROR') {
          _showError(message['message']);
        }
      });
    } else {
      _showError("Token invalide");
    }
  }

  Future<void> _updateCoursePresence(int subjectHourId) async {
    ref.read(dailyCourseProvider.notifier).markAsPresent(subjectHourId);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Connexion en cours..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
