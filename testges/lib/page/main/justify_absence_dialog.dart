import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../Model/absence.dart';
import '../../service/provider/unconfirmed_absence_provider.dart';
import '../../service/upload_service.dart';

void ShowJustifyAbsenceBox(BuildContext context, Absence absence, WidgetRef ref) {
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
                        Navigator.of(context).pop();
                        if (_filePath != null) {
                          final uploadedFileUrl = await uploadFileToCloudinary(_filePath!);
                          if (uploadedFileUrl != null) {

                            print('File uploaded to: $uploadedFileUrl');

                          } else {
                            print('File upload failed');
                          }
                        }
                      },
                      child: Text('Soumettre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
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
