import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/unconfirmed_absence_provider.dart';
import '../../Model/absence.dart';

class AbsencePage extends ConsumerStatefulWidget {
  @override
  _AbsencePageState createState() => _AbsencePageState();
}

class _AbsencePageState extends ConsumerState<AbsencePage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    final token = ref.read(authenticationProvider.notifier).state;
    if (token != null) {
      await ref.read(unconfirmedAbsenceProvider.notifier).loadUnconfirmedAbsences(token);
    }
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final absences = ref.watch(unconfirmedAbsenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Absence Page'),
        backgroundColor: Colors.yellow[700],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: absences.length,
          itemBuilder: (context, index) {
            final absence = absences[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: ListTile(
                  title: Text(
                    '${absence.subject.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    'Prof: ${absence.subject.teacher.firstname} ${absence.subject.teacher.lastname}\n'
                        'Horaire: ${_formatDate(absence.dateStart)} - ${_formatDate(absence.dateEnd)}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Action à réaliser lors du clic sur la carte
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
