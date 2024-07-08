import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/service/provider/qcm_provider.dart';
import 'package:testges/service/authentication_provider.dart';

class QcmPage extends ConsumerStatefulWidget {
  @override
  _QcmPageState createState() => _QcmPageState();
}

class _QcmPageState extends ConsumerState<QcmPage> {
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
            ),
          );
        },
      ),
    );
  }
}
