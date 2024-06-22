import 'package:flutter_riverpod/flutter_riverpod.dart';

final authenticationProvider = StateProvider<bool>((ref) {
  return false; // Initial state is not authenticated
});
