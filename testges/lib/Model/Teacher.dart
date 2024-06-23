class Teacher {
  final int id;
  final String email;
  final String lastname;
  final String firstname;
  final String num;

  Teacher({
    required this.id,
    required this.email,
    required this.lastname,
    required this.firstname,
    required this.num,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['user_Id'],
      email: json['user_email'],
      lastname: json['user_lastname'],
      firstname: json['user_firstname'],
      num: json['user_num'],
    );
  }
}
