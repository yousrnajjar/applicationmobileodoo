import 'package:smartpay/api/session.dart';

import '../models/holidays_models.dart';

class HolidaysAPI {
  final Session session;

  HolidaysAPI(this.session);
  
  Future<Holiday> defaultGet () async {
    var data = {
      "model": "hr.leave",
      "method": "default_get",
      "args": [Holiday.defaultFields],
      "kwargs": {
        "context": session.defaultContext
      }
    };
    var result = await session.callKw(data) as List;

    return Holiday.fromJSON(result[0]);
  }
  Future<List<Holiday>> getMyHolidays(int myUid) async {
    var data = {
      "model": "hr.leave",
      "method": "search_read",
      "args": [
        [
          ["user_id", "=", myUid]
        ],
        Holiday.allFields
      ],
      "kwargs": {
        "context" : session.defaultContext
      }

    };
    var result = await session.callKw(data);
    result = result as List;
    return [for (var res in result) Holiday.fromJSON(res)];
  }

  Future<int> createHolidays(Map<String, dynamic> newHolidays) async {
    var data = {
      "model": "hr.leave",
      "method": "create",
      "args": [],
      "kwargs": {
        
      }
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
      "kwargs": {
        "context": session.defaultContext
      }
    };
    var result = await session.callKw(data) as List;
    return [for (var res in result) HolidayType(res)];
  }
}
