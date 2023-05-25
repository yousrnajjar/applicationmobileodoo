import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/models/attendance_models.dart';

class AttendanceListNotifier extends StateNotifier<List<Attendance>> {
  AttendanceListNotifier(): super(<Attendance>[]);

  void setAttendances(List<Attendance> attendances) {
    state = attendances;
  }
}

final attendancesProvider = StateNotifierProvider<AttendanceListNotifier, List<Attendance>>((ref) {
  return AttendanceListNotifier();
});