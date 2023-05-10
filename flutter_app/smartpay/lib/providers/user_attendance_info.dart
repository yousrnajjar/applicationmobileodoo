import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/models.dart';

class CurrentEmployeeNotifier extends StateNotifier<Employee> {
  CurrentEmployeeNotifier() : super(Employee.empty());

  void setEmployee(Employee newEmployee) {
    state = newEmployee;
  }
}

final currentEmployeeAttendanceProvider = StateNotifierProvider<CurrentEmployeeNotifier, Employee>(
  (ref) => CurrentEmployeeNotifier(),
);
