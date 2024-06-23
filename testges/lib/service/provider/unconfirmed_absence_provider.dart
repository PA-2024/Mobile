import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/service/unconfirmed_absence_service.dart';
import 'package:testges/Model/absence.dart';

final unconfirmedAbsenceProvider = StateNotifierProvider<UnconfirmedAbsenceNotifier, List<Absence>>((ref) {
  return UnconfirmedAbsenceNotifier();
});

class UnconfirmedAbsenceNotifier extends StateNotifier<List<Absence>> {
  UnconfirmedAbsenceNotifier() : super([]);

  final UnconfirmedAbsenceService _absenceService = UnconfirmedAbsenceService();

  Future<void> loadUnconfirmedAbsences(String token) async {
    try {
      final absences = await _absenceService.getUnconfirmedAbsences(token);
      print('Absences loaded: $absences');
      state = absences;
    } catch (e) {
      print('Error loading absences: $e');
      state = [];  // Clear state on error
    }
  }
}
