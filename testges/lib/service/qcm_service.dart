import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testges/Model/qcm.dart';

class QCMService {
  Future<List<QCM>> getQCMs(String token, String startDate, String endDate) async {
    final response = await http.get(
      Uri.parse('https://apigessignrecette-c5e974013fbd.herokuapp.com/api/QCM/qcmByRange?StartDate=$startDate&EndDate=$endDate'),
      headers: {
        'accept': 'text/plain',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((json) => QCM.fromJson(json)).toList();
    } else {
      print("error");
      throw Exception('Failed to load QCMs');
    }
  }
}
