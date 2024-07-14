import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final String result;

  FeedbackPage({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[200]!, Colors.yellow[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AlertDialog(
            title: Text('Résultat'),
            content: Text(
              result == "Correct" ? 'Bonne réponse!' : 'Mauvaise réponse.',
              style: TextStyle(
                fontSize: 24,
                backgroundColor: result == "Correct" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
                style: ElevatedButton.styleFrom(
                   backgroundColor : result == "Correct" ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
