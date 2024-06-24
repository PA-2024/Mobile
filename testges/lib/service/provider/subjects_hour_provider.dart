import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testges/Model/subjects_hour.dart';
import 'package:testges/service/subjects_hour_service.dart';

final subjectsHourProvider = StateNotifierProvider<SubjectsHourNotifier, List<SubjectsHour>>((ref) {
  return SubjectsHourNotifier();
});

class SubjectsHourNotifier extends StateNotifier<List<SubjectsHour>> {
  SubjectsHourNotifier() : super([]);

  final SubjectsHourService _subjectsHourService = SubjectsHourService();

  Future<void> loadSubjectsHour(String token, String startDate, String endDate) async {
    try {
      final subjectsHours = await _subjectsHourService.getSubjectsHourByDateRange(token, startDate, endDate);
      state = subjectsHours;
    } catch (e) {
      print('Error loading subjects hours: $e');
      state = [];  // Clear state on error
    }
  }
}
