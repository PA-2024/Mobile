import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../service/authentication_provider.dart';
import '../../service/provider/unconfirmed_absence_provider.dart';
import '../../Model/absence.dart';
import '../../service/upload_service.dart';

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

  Future<void> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {

    } else {
      print('Permission de stockage manquante');
    }
  }

  void ShowJustifyAbsenceBox(BuildContext context, Absence absence) {
    final TextEditingController _reasonController = TextEditingController();
    String? _filePath;
    String? _fileName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Justifier l'absence",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          labelText: 'Motif',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _requestStoragePermission();
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if (result != null && result.files.single.path != null) {
                            _filePath = result.files.single.path!;
                            _fileName = result.files.single.name;
                            setState(() {});
                          }
                        },
                        child: Text('Charger le justificatif'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                        ),
                      ),
                      if (_filePath != null) Text('Fichier: $_fileName'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_filePath != null) {
                            final uploadedFileUrl = await uploadFileToCloudinary(_filePath!);
                            if (uploadedFileUrl != null) {
                              final token = ref.read(authenticationProvider.notifier).state;
                              if (token != null) {
                                await ref.read(unconfirmedAbsenceProvider.notifier).justifyAbsence(
                                  token,
                                  absence.id,
                                  _reasonController.text,
                                  uploadedFileUrl,
                                );
                                Navigator.of(context).pop();
                              }
                            } else {
                              print('File upload failed');
                            }
                          } else {
                            print('No file selected');
                          }
                        },
                        child: Text('Soumettre'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // background (button) color
                          foregroundColor: Colors.white, // foreground (text) color
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final absences = ref.watch(unconfirmedAbsenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Vos absences'),
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
        child: SmartRefresher(
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
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      ShowJustifyAbsenceBox(context, absence);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
