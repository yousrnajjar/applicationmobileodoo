import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/models/attendance_models.dart';

class EmployeeListNotifier extends StateNotifier<List<EmployeeAllInfo>> {
  EmployeeListNotifier() : super(<EmployeeAllInfo>[]);

  void setEmployees(List<EmployeeAllInfo> employees) {
    state = employees;
  }
}

final employeesProvider =
    StateNotifierProvider<EmployeeListNotifier, List<EmployeeAllInfo>>((ref) {
  return EmployeeListNotifier();
});
