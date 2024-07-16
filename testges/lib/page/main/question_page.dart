import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testges/service/authentication_provider.dart';
import 'package:testges/service/provider/qcm_provider.dart';

class QuestionPage extends ConsumerStatefulWidget {
  final String question;
  final List<Map<String, dynamic>> options;

  QuestionPage({required this.question, required this.options});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends ConsumerState<QuestionPage> {
  final List<int> _selectedOptions = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: AppBar(
          title: Text('Question'),
          backgroundColor: Colors.yellow[700],
          automaticallyImplyLeading: false, // Remove the back arrow
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
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.options.length,
                    itemBuilder: (context, index) {
                      final option = widget.options[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedOptions.contains(option['id'])) {
                              _selectedOptions.remove(option['id']);
                            } else {
                              _selectedOptions.add(option['id']);
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _selectedOptions.contains(option['id'])
                                ? Color(0xFF0056b3)
                                : _getOptionColor(index),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option['text'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_selectedOptions.contains(option['id']))
                                Icon(Icons.check, color: Colors.white),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                _isSubmitting
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isSubmitting = true;
                    });
                    final token = ref.read(authenticationProvider);
                    if (token != null) {
                      final decodedToken = JwtDecoder.decode(token);
                      final studentId = decodedToken['Student_Id'].toString();
                      ref.read(qcmProvider.notifier).sendAnswer(studentId, _selectedOptions);
                    }
                    setState(() {
                      _isSubmitting = false;
                    });
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
      ),
    );
  }

  Color _getOptionColor(int index) {
    switch (index % 4) {
      case 0:
        return Color(0xFFFF6F61);
      case 1:
        return Color(0xFF6A4C93);
      case 2:
        return Color(0xFFFFD700);
      case 3:
        return Color(0xFF28A745);
      default:
        return Colors.grey;
    }
  }
}
