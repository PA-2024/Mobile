import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/unconfirmed_absence_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final absences = ref.watch(unconfirmedAbsenceProvider);
    print(absences.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('Absence Page'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemCount: absences.length,
          itemBuilder: (context, index) {
            final absence = absences[index];

            return ListTile(
              title: Text('${absence.subject.name} with ${absence.subject.teacher.firstname} ${absence.subject.teacher.lastname}'),
              subtitle: Text('Room: ${absence.room}, Building: ${absence.building.name}'),
              trailing: Text(
                '${absence.dateStart} - ${absence.dateEnd}',
                style: TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }
}
