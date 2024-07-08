import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testges/service/provider/qcm_provider.dart';
import 'package:testges/service/authentication_provider.dart';

class QcmPage extends ConsumerStatefulWidget {
  @override
  _QcmPageState createState() => _QcmPageState();
}

class _QcmPageState extends ConsumerState<QcmPage> {
  String _currentMessage = "";

  @override
  void initState() {
    super.initState();
    _loadQCMs();
  }

  Future<void> _loadQCMs() async {
    final token = ref.read(authenticationProvider);
    if (token != null) {
      await ref.read(qcmProvider.notifier).loadQCMs(token, '2021-01-01', '2026-01-01'); // TODO A FIX PAR LA SUITE
    }
  }

  void _connectWebSocket(String idQCM) {
    print(idQCM);
    final url = 'wss://apigessignrecette-c5e974013fbd.herokuapp.com/qcm/' + idQCM;
    ref.read(qcmProvider.notifier).connectWebSocket(url);
    ref.read(qcmProvider.notifier).messages.listen((message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(dynamic message) {
    print('Received message: $message');
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
            question: parsedMessage['text'],
            options: List<Map<String, dynamic>>.from(parsedMessage['options']),
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
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
      body: qcms.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: qcms.length,
        itemBuilder: (context, index) {
          final qcm = qcms[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              leading: Icon(Icons.quiz, color: Colors.orange[700]),
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
          );
        },
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

class WaitingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('En attente des questions'),
      ),
      body: Center(
        child: Text('En attente des questions...'),
      ),
    );
  }
}

class QuestionPage extends StatelessWidget {
  final String question;
  final List<Map<String, dynamic>> options;

  QuestionPage({required this.question, required this.options});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...options.map((option) => ListTile(
              title: Text(option['text']),
              leading: Icon(Icons.radio_button_unchecked),
              onTap: () {
                // Handle answer selection
              },
            )),
          ],
        ),
      ),
    );
  }
}
