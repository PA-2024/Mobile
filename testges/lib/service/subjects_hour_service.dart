import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/subjects_hour.dart';

class SubjectsHourService {
  final String _baseUrl = 'https://apigessignrecette-c5e974013fbd.herokuapp.com/api';

  Future<List<SubjectsHour>> getSubjectsHourByDateRange(String token, String startDate, String endDate) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/SubjectsHour/byDateRange?StartDate=$startDate&EndDate=$endDate'),
      headers: <String, String>{
        'accept': 'text/plain',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<SubjectsHour> subjectsHours = body.map((dynamic item) => SubjectsHour.fromJson(item)).toList();
      return subjectsHours;
    } else {
      print('Failed to load subjects hours. Status code: ${response.statusCode}');
      throw Exception('Failed to load subjects hours');
    }
  }
}
