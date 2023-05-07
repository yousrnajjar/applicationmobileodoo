import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/attendance.dart';

class UserAttendanceInoNotifier extends StateNotifier<EmployeeAttendanceInfo> {
  UserAttendanceInoNotifier() : super(EmployeeAttendanceInfo.empty());

  void setAttendance(EmployeeAttendanceInfo newAttendanceInfo) {
    state = newAttendanceInfo;
  }
}

final userAttendanceProvider = StateNotifierProvider<UserAttendanceInoNotifier, EmployeeAttendanceInfo>(
  (ref) => UserAttendanceInoNotifier(),
);
