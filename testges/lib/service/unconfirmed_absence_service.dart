import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/absence.dart';

class UnconfirmedAbsenceService {
  Future<List<Absence>> getUnconfirmedAbsences(String token) async {
    final response = await http.get(
      Uri.parse('https://apipa2024-a0a3b2c9ce54.herokuapp.com/api/Presence/unconfirmed'),
      headers: {
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Absence.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load absences');
    }
  }

  Future<http.Response> justifyAbsence(String token, int absenceId, String comment, String fileUrl) async {
    final response = await http.post(
      Uri.parse('https://apipa2024-a0a3b2c9ce54.herokuapp.com/CreateProofAbsence/$absenceId'),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'proofAbsence_StudentComment': comment,
        'proofAbsence_UrlFile': fileUrl,
      }),
    );

    return response;
  }
}
