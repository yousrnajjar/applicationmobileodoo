import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/models/holidays_models.dart';

class HolidaysListNotifier extends StateNotifier<List<Holiday>> {
  HolidaysListNotifier() : super(<Holiday>[]);

  void setMyHolidays(List<Holiday> holidays) {
    state = holidays;
  }

  int? getEmployeeId() {
    return state.isNotEmpty ? state[0].employeeId[0] : null;
  }
}

final myHolidaysProvider =
    StateNotifierProvider<HolidaysListNotifier, List<Holiday>>((ref) {
  return HolidaysListNotifier();
});
