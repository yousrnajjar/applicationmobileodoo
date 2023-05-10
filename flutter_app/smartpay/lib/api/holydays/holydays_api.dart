import 'package:smartpay/api/auth/session.dart';

import 'holydays_models.dart';

class HolydaysAPI {
  final Session session;

  HolydaysAPI(this.session);
  var holydaysFields = [
    "state",
    "holiday_status_id",
    "name",
    "date_from",
    "date_to",
    "duration_display",
    "payslip_status",
    "employee_id",
    "user_id"
  ];
  Future<List<Holydays>> getMyHolydays(int myUid) async {
    var data = {
      "model": "hr.leave",
      "method": "search_read",
      "args": [
        [
          ["user_id", "=", myUid]
        ],
        holydaysFields
      ],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;
    return [for (var res in result) Holydays.fromJSON(res)];
  }

  Future<Holydays> getEmpty() async {
    var data = {
      "model": "hr.leave",
      "method": "default_get",
      "args": [holydaysFields],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;

    return Holydays.fromJSON(result[0]);
  }

  Future<int> createHolydays(Holydays newHolydays) async {
    var data = {
      "model": "hr.employee",
      "method": "attendance_manual",
      "args": [newHolydays.toJson()],
      "kwargs": {}
    };
    // TODO : VAlidation error
    var result = (await session.callKw(data));
    return result;
  }
}
