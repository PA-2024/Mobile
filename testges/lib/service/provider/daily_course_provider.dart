import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../daily_course_service.dart';
import '../../model/daily_course_model.dart';

final dailyCourseProvider = StateNotifierProvider<DailyCourseNotifier, List<DailyCourse>>((ref) {
  return DailyCourseNotifier();
});

class DailyCourseNotifier extends StateNotifier<List<DailyCourse>> {
  DailyCourseNotifier() : super([]);

  final DailyCourseService _dailyCourseService = DailyCourseService();

  Future<void> loadDailyCourses(String token) async {
    try {
      final dailyCourses = await _dailyCourseService.getDailyCourses(token);
      state = dailyCourses;
    } catch (e) {
      print('Error loading daily courses: $e');
      state = [];
      throw Exception('Failed to load daily courses');
    }
  }
}
