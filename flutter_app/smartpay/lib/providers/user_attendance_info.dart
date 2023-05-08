import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/models.dart';

class CurrentEmployeeNotifier extends StateNotifier<Employee> {
  CurrentEmployeeNotifier() : super(Employee.empty());

  void setAttendance(Employee newAttendanceInfo) {
    state = newAttendanceInfo;
  }
}

final currentEmployeeProvider = StateNotifierProvider<CurrentEmployeeNotifier, Employee>(
  (ref) => CurrentEmployeeNotifier(),
);
