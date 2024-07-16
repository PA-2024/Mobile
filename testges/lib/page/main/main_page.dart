import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testges/service/authentication_provider.dart';
import 'package:testges/service/provider/daily_course_provider.dart';
import 'package:testges/service/provider/presence_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:testges/page/main/QrScan.dart';
import 'package:testges/page/login_page.dart';

class MainPage extends ConsumerStatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late ConfettiController _confettiController;
  StreamSubscription? _messageSubscription;
  bool _isProcessing = false;
  bool _isDialogOpen = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
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
    ref.read(authenticationProvider.notifier).clearToken();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _messageSubscription?.cancel();
    _isMounted = false;
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
      await _handleQRCodeScan(code, subjectHourId);
    }
  }

  Future<void> _handleQRCodeScan(String code, int subjectHourId) async {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      final studentId = decodedToken['Student_Id'].toString();
      final message = "validate $subjectHourId $studentId $code";
      final url = 'wss://apipa2024-a0a3b2c9ce54.herokuapp.com/ws';
      final presenceNotifier = ref.read(presenceProvider.notifier);

      print('Connecting to WebSocket');
      presenceNotifier.connectWebSocket(url);

      _showLoadingDialog(); // Show loading dialog

      _messageSubscription?.cancel();
      _messageSubscription = presenceNotifier.messages.listen((message) async {
        print('Received message: $message');
        final parsedMessage = jsonDecode(message);
        final action = parsedMessage['action'];
        print('Received action: $action');
        if (_isDialogOpen) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          _isDialogOpen = false;
        }

        if (action == 'VALIDATED') {
          if (_isMounted) {
            print("ON EST RENTRE ICI");
            _confettiController.play();
            ref.read(dailyCourseProvider.notifier).markAsPresent(subjectHourId);
            setState(() {});
            _messageSubscription?.cancel();
          }
        } else if (action == 'ERROR') {
          if (_isMounted) {
            _showError(parsedMessage['message']);
            _messageSubscription?.cancel();
          }
        }
      });

      presenceNotifier.sendMessage(message);
    } else {
      if (_isMounted) {
        _showError("Token invalide");
      }
    }
  }

  void _showLoadingDialog() {
    if (_isMounted) {
      _isDialogOpen = true;
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
      ).then((_) {
        _isDialogOpen = false;
      });
    }
  }

  void _showError(String message) {
    if (_isMounted) {
      _isDialogOpen = true;
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
                  if (_isMounted) {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    _isDialogOpen = false;
                  }
                },
              ),
            ],
          );
        },
      ).then((_) {
        _isDialogOpen = false;
      });
    }
  }
}
