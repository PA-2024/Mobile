import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/daily_course_model.dart';

class DailyCourseService {
  Future<List<DailyCourse>> getDailyCourses(String token) async {
    try {
      print('Sending request to load daily courses');
      final response = await http.get(
        Uri.parse('https://apigessignrecette-c5e974013fbd.herokuapp.com/api/Presence/OneDay'),
        headers: {
          'Authorization': token,
          'accept': 'text/plain',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => DailyCourse.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load daily courses');
      }
    } catch (e) {
      print('Error in getDailyCourses: $e');
      throw e;
    }
  }
}
