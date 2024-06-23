import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/absence.dart';

class UnconfirmedAbsenceService {
  final String _baseUrl = 'https://apigessignrecette-c5e974013fbd.herokuapp.com/api';

  Future<List<Absence>> getUnconfirmedAbsences(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/Presence/unconfirmed'),
      headers: <String, String>{
        'accept': 'text/plain',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Absence> absences = body.map((dynamic item) => Absence.fromJson(item)).toList();
      return absences;
    } else {
      print('Failed to load unconfirmed absences. Status code: ${response.statusCode}');
      throw Exception('Failed to load unconfirmed absences');
    }
  }
}
