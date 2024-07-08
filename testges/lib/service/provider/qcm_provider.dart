import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/Model/qcm.dart';
import 'package:testges/service/qcm_service.dart';
import 'package:testges/service/qcm_websocket_service.dart';

final qcmProvider = StateNotifierProvider<QCMNotifier, List<QCM>>((ref) {
  return QCMNotifier();
});

class QCMNotifier extends StateNotifier<List<QCM>> {
  QCMNotifier() : super([]);

  final QCMService _qcmService = QCMService();
  final QCMWebSocketService _webSocketService = QCMWebSocketService();

  Future<void> loadQCMs(String token, String startDate, String endDate) async {
    try {
      final qcms = await _qcmService.getQCMs(token, startDate, endDate);
      state = qcms;
    } catch (e) {
      state = [];
    }
  }

  void connectWebSocket(String url) {
    _webSocketService.connect(url);
  }

  void joinQCM(String qcmId, String token, String studentId, String studentName) {
    _webSocketService.joinQCM(qcmId, token, studentId, studentName);
  }

  Stream<dynamic> get messages => _webSocketService.messages;

  void sendAnswer(String qcmId, String studentId, int answer) {
    _webSocketService.sendAnswer(qcmId, studentId, answer);
  }

  void disconnectWebSocket() {
    _webSocketService.disconnect();
  }
}
