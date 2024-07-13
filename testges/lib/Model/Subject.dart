import 'package:testges/Model/Teacher.dart';

class Subject {
  final int id;
  final String name;
  final Teacher teacher;

  Subject({
    required this.id,
    required this.name,
    required this.teacher,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['subjects_Id'],
      name: json['subjects_Name'],
      teacher: Teacher.fromJson(json['teacher']),
    );
  }
}