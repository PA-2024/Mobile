import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testges/service/provider/qcm_provider.dart';

import '../../service/authentication_provider.dart';

class QuestionPage extends ConsumerStatefulWidget {
  final String qcmId;
  final String question;
  final List<Map<String, dynamic>> options;

  QuestionPage({required this.qcmId, required this.question, required this.options});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends ConsumerState<QuestionPage> {
  final List<int> _selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question'),
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.question,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ...widget.options.map((option) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(option['text']),
                  leading: Icon(
                    _selectedOptions.contains(option['id'])
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onTap: () {
                    setState(() {
                      if (_selectedOptions.contains(option['id'])) {
                        _selectedOptions.remove(option['id']);
                      } else {
                        _selectedOptions.add(option['id']);
                      }
                    });
                  },
                ),
              )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final token = ref.read(authenticationProvider);
                  if (token != null) {
                    final decodedToken = JwtDecoder.decode(token);
                    final studentId = decodedToken['Student_Id'].toString();
                    ref.read(qcmProvider.notifier).sendAnswer(studentId, _selectedOptions);
                  }
                },
                child: Text('Envoyer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
