class DailyCourse {
  final int id;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String subjectName;
  final String teacherFirstName;
  final String teacherLastName;
  final bool studentIsPresent;

  DailyCourse({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.subjectName,
    required this.teacherFirstName,
    required this.teacherLastName,
    required this.studentIsPresent,
  });

  factory DailyCourse.fromJson(Map<String, dynamic> json) {
    return DailyCourse(
      id: json['subjectsHour_Id'],
      dateStart: DateTime.parse(json['subjectsHour_DateStart']),
      dateEnd: DateTime.parse(json['subjectsHour_DateEnd']),
      subjectName: json['subjectsHour_Subject']['subjects_Name'],
      teacherFirstName: json['subjectsHour_Subject']['teacher']['user_firstname'],
      teacherLastName: json['subjectsHour_Subject']['teacher']['user_lastname'],
      studentIsPresent: json['studentIsPresent'],
    );
  }

}
