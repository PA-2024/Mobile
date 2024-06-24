import 'Building.dart';
import 'Teacher.dart';
import 'Subject.dart';

class SubjectsHour {
  final int id;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String room;
  final Building building;
  final String? TeacherComment;
  final Subject subject;

  SubjectsHour({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.room,
    required this.building,
    required this.subject,
    required this.TeacherComment,
  });

  factory SubjectsHour.fromJson(Map<String, dynamic> json) {
    return SubjectsHour(
      id: json['subjectsHour_Id'],
      dateStart: DateTime.parse(json['subjectsHour_DateStart']),
      dateEnd: DateTime.parse(json['subjectsHour_DateEnd']),
      room: json['subjectsHour_Room'],
      building: Building.fromJson(json['building']),
      subject: Subject.fromJson(json['subject']),
      TeacherComment: json['subjectsHour_TeacherComment'],
    );
  }
}

