import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'https://apigessignrecette-c5e974013fbd.herokuapp.com/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/Auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_email': email,
        'user_password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }
}
