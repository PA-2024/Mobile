class QCM {
  final int id;
  final String title;

  QCM({required this.id, required this.title});

  factory QCM.fromJson(Map<String, dynamic> json) {
    return QCM(
      id: json['id'],
      title: json['title'],
    );
  }
}
