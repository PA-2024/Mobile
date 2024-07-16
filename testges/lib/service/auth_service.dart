import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'https://apigessignrecette-c5e974013fbd.herokuapp.com/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Auth/student/login'),
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
        throw Exception('Impossible de se connecter, vérifier vos identifiants');
      }
    } catch (e) {
      throw Exception('Nous rencontrons un problème interne, merci de réessayer plus tard.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Auth/reset?email=$email'),
        headers: <String, String>{
          'accept': 'text/plain',
        },
        body: '',
      );

      if (response.statusCode != 200) {
        throw Exception('Impossible d\'envoyer l\'email de réinitialisation.');
      }
    } catch (e) {
      throw Exception('Nous rencontrons un problème interne, merci de réessayer plus tard.');
    }
  }

}
