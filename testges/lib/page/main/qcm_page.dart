import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testges/service/provider/qcm_provider.dart';
import 'package:testges/service/authentication_provider.dart';
import 'question_page.dart';
import 'waiting_page.dart';
import 'feedback_page.dart';

class QcmPage extends ConsumerStatefulWidget {
  @override
  _QcmPageState createState() => _QcmPageState();
}

class _QcmPageState extends ConsumerState<QcmPage> with SingleTickerProviderStateMixin {
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
    _loadQCMs();
    _controller.forward();
  }

  Future<void> _loadQCMs() async {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      await ref.read(qcmProvider.notifier).loadQCMs(token, '2021-01-01', '2026-01-01');
    }
  }

  void _connectWebSocket(String idQCM) {
    final url = 'wss://apigessignrecette-c5e974013fbd.herokuapp.com/qcm/' + idQCM;
    ref.read(qcmProvider.notifier).connectWebSocket(url);
    ref.read(qcmProvider.notifier).messages.listen((message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(dynamic message) {
    final parsedMessage = jsonDecode(message);
    final action = parsedMessage['action'];

    if (action == 'CONNECT') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingPage(),
        ),
      );
    } else if (action == 'ERROR') {
      _showError(parsedMessage['message']);
    } else if (action == 'QUESTION') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionPage(
            qcmId: parsedMessage['qcmId'],
            question: parsedMessage['text'],
            options: List<Map<String, dynamic>>.from(parsedMessage['options']),
          ),
        ),
      );
    } else if (action == 'FEEDBACK') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackPage(result: parsedMessage['result']),
        ),
      );
    }
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    ref.read(qcmProvider.notifier).disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qcms = ref.watch(qcmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Vos QCM de la journée'),
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
        child: qcms.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, [Nom de l\'utilisateur]!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Voici vos QCM pour aujourd\'hui:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: qcms.length,
                itemBuilder: (context, index) {
                  final qcm = qcms[index];
                  return SlideTransition(
                    position: _animation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[700],
                            child: Icon(Icons.quiz, color: Colors.white),
                          ),
                          title: Text(
                            qcm.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          onTap: () {
                            _connectWebSocket(qcm.id.toString());
                            _joinQCM(qcm.id.toString());
                          },
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
    );
  }

  void _joinQCM(String qcmId) {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      final studentId = decodedToken['Student_Id'].toString();
      final studentName = decodedToken['unique_name'];
      ref.read(qcmProvider.notifier).joinQCM(qcmId, token, studentId, studentName);
    }
  }
}
