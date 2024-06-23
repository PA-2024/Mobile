import 'package:http/http.dart' as http;
import 'dart:convert';

class AbsenceService {
  final String _baseUrl = 'https://apigessignrecette-c5e974013fbd.herokuapp.com/api';

  Future<Map<String, dynamic>> getAttendanceSummary(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Presence/attendance-summary'),
      headers: <String, String>{
        'accept': 'text/plain',
        'Authorization': token,
      },
    );
    
    print('Bearer $token');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load attendance summary');
    }
  }
}
