import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class QCMWebSocketService {
  late WebSocketChannel _channel;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void joinQCM(String qcmId, String token, String studentId, String studentName) {
    var joinMessage = jsonEncode({
      'action': 'JOIN_STUDENT',
      'qcmId': qcmId,
      'token': token,
      'studentId': studentId,
      'studentName': studentName,
    });
    _channel.sink.add(joinMessage);
  }

  void sendAnswer(String qcmId, String studentId, int answer) {
    var answerMessage = jsonEncode({
      'action': 'ANSWER',
      'qcmId': qcmId,
      'studentId': studentId,
      'answer': answer,
    });
    _channel.sink.add(answerMessage);
  }

  Stream<dynamic> get messages => _channel.stream;

  void disconnect() {
    _channel.sink.close();
  }
}
