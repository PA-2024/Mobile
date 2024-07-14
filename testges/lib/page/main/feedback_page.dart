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
            content: Row(
              children: [
                Icon(
                  result == "Correct" ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: result == "Correct" ? Colors.green : Colors.red,
                  size: 48,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result == "Correct" ? 'Bonne réponse!' : 'Mauvaise réponse.',
                    style: TextStyle(
                      fontSize: 24,
                      color: result == "Correct" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
