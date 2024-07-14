import 'package:testges/Model/Building.dart';
import 'package:testges/Model/Subject.dart';

class Absence {
  final int id;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String room;
  final Building building;
  final Subject subject;
  final bool? PresenceId;

  Absence({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.room,
    required this.building,
    required this.subject,
    required this.PresenceId
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      id: json['subjectsHour_Id'],
      PresenceId : json['Presence_id'],
      dateStart: DateTime.parse(json['subjectsHour_DateStart']),
      dateEnd: DateTime.parse(json['subjectsHour_DateEnd']),
      room: json['subjectsHour_Room'],
      building: Building.fromJson(json['building']),
      subject: Subject.fromJson(json['subject']),

    );
  }
}





