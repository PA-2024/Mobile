import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/service/qcm_websocket_service.dart';
import 'package:testges/Model/qcm.dart';
import '../qcm_service.dart';

final qcmProvider = StateNotifierProvider<QCMNotifier, List<QCM>>((ref) => QCMNotifier(ref));

class QCMNotifier extends StateNotifier<List<QCM>> {
  QCMNotifier(this.ref) : super([]);

  final Ref ref;
  final QCMWebSocketService _webSocketService = QCMWebSocketService();
  final QCMService _qcmService = QCMService();

  void connectWebSocket(String url) {
    _webSocketService.connect(url);
  }

  void joinQCM(String qcmId, String token, String studentId, String studentName) {
    _webSocketService.joinQCM(qcmId, token, studentId, studentName);
  }

  void sendAnswer(String studentId, List<int> answers) {
    _webSocketService.sendAnswer(studentId, answers);
  }

  Stream<dynamic> get messages => _webSocketService.messages;

  Future<void> loadQCMs(String token, String startDate, String endDate) async {
    try {
      final qcms = await _qcmService.getQCMs(token, startDate, endDate);
      state = qcms;
    } catch (e) {
      state = [];
    }
  }

  void disconnectWebSocket() {
    _webSocketService.disconnect();
  }
}
