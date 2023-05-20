import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/exceptions/api_exceptions.dart';

import 'holidays_models.dart';

class HolidaysAPI {
  final Session session;

  HolidaysAPI(this.session);
  var holidaysFields = [
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
  Future<List<Holiday>> getMyHolidays(int myUid) async {
    var data = {
      "model": "hr.leave",
      "method": "search_read",
      "args": [
        [
          ["user_id", "=", myUid]
        ],
        holidaysFields
      ],
      "kwargs": {}
    };
    var result = await session.callKw(data);
    result = result as List;
    return [for (var res in result) Holiday.fromJSON(res)];
  }

  Future<Holiday> getEmpty() async {
    var data = {
      "model": "hr.leave",
      "method": "default_get",
      "args": [holidaysFields],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;

    return Holiday.fromJSON(result[0]);
  }

  Future<int> createHolidays(Map<String, dynamic> newHolidays) async {
    var data = {
      "model": "hr.leave",
      "method": "create",
      "args": [newHolidays],
      "kwargs": {}
    };
    try {
      var result = (await session.callKw(data));
      return result;
    } on Exception {
      rethrow;
    }
  }

  Future<List<HolidayType>> getHolidayTypes() async {
    var data = {
      "model": "hr.leave.type",
      "method": "search_read",
      "args": [
        [
          ["valid", "=", true]
        ]
      ],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;
    return [for (var res in result) HolidayType(res)];
  }
}
