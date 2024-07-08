import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/Model/qcm.dart';
import 'package:testges/service/qcm_service.dart';

final qcmProvider = StateNotifierProvider<QCMNotifier, List<QCM>>((ref) {
  return QCMNotifier();
});

class QCMNotifier extends StateNotifier<List<QCM>> {
  QCMNotifier() : super([]);

  final QCMService _qcmService = QCMService();

  Future<void> loadQCMs(String token, String startDate, String endDate) async {
    try {
      final qcms = await _qcmService.getQCMs(token, startDate, endDate);
      state = qcms;
    } catch (e) {
      state = [];
    }
  }
}
