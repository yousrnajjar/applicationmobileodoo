import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/models.dart';

class CurrentEmployeeNotifier extends StateNotifier<EmployeeAllInfo> {
  CurrentEmployeeNotifier() : super(EmployeeAllInfo());

  void setEmployee(EmployeeAllInfo employee) {
    state = employee;
  }
}

final currentEmployeeProvider =
    StateNotifierProvider<CurrentEmployeeNotifier, EmployeeAllInfo>((ref) {
  return CurrentEmployeeNotifier();
});
