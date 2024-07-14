import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../unconfirmed_absence_service.dart';
import '../../Model/absence.dart';

final unconfirmedAbsenceProvider = StateNotifierProvider<UnconfirmedAbsenceNotifier, List<Absence>>((ref) {
  return UnconfirmedAbsenceNotifier();
});

class UnconfirmedAbsenceNotifier extends StateNotifier<List<Absence>> {
  UnconfirmedAbsenceNotifier() : super([]);

  final UnconfirmedAbsenceService _unconfirmedAbsenceService = UnconfirmedAbsenceService();

  Future<void> loadUnconfirmedAbsences(String token) async {
    try {
      final absences = await _unconfirmedAbsenceService.getUnconfirmedAbsences(token);
      state = absences;
    } catch (e) {
      print('Error loading unconfirmed absences: $e');
      state = [];
    }
  }

  Future<void> justifyAbsence(String token, int absenceId, String comment, String fileUrl) async {
    try {
      final response = await _unconfirmedAbsenceService.justifyAbsence(token, absenceId, comment, fileUrl);
      if (response.statusCode == 200) {
        state = state.where((absence) => absence.id != absenceId).toList();
      } else {
        print('Error justifying absence: ${response.statusCode}');
      }
    } catch (e) {
      print('Error justifying absence: $e');
    }
  }
}
