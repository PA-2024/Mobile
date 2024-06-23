import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/service/absence_service.dart';

final absenceProvider = StateNotifierProvider<AbsenceNotifier, Map<String, dynamic>>((ref) {
  return AbsenceNotifier();
});

class AbsenceNotifier extends StateNotifier<Map<String, dynamic>> {
  AbsenceNotifier() : super({});

  final AbsenceService _absenceService = AbsenceService();

  Future<void> loadAttendanceSummary(String token) async {
    try {
      final summary = await _absenceService.getAttendanceSummary(token);
      state = summary;
    } catch (e) {
      state = {'error': e.toString()};
    }
  }
}
