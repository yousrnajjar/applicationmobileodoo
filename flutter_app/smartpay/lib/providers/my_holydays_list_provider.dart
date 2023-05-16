import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/holydays/holydays_models.dart';

class HolydaysListNotifier extends StateNotifier<List<Holyday>> {
  HolydaysListNotifier() : super(<Holyday>[]);

  void setMyHolydays(List<Holyday> holydays) {
    state = holydays;
  }

  int? getEmployeeId() {
    return state.isNotEmpty ? state[0].employeeId[0] : null;
  }
}

final myHolydaysProvider =
    StateNotifierProvider<HolydaysListNotifier, List<Holyday>>((ref) {
  return HolydaysListNotifier();
});
