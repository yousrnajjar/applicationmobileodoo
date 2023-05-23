import 'package:smartpay/api/session.dart';
import 'package:smartpay/models/attendance_models.dart';

class EmployeeAPI {
  final Session session;

  EmployeeAPI(this.session);

  Future<List<EmployeeAllInfo>> getEmployees(int uid) async {
    var data = {
      "model": "hr.employee",
      "method": "search_read",
      "args": [[]],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;
    return [for (var res in result) EmployeeAllInfo.fromJson(res)];
  }

  Future<EmployeeAllInfo> getEmployee(int uid) async {
    var data = {
      "model": "hr.employee",
      "method": "search_read",
      "args": [
        [
          ["user_id", "=", uid]
        ],
        ["image_128", "attendance_state", "name", "hours_today"]
      ],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;

    return EmployeeAllInfo.fromJson(result[0]);
  }
}

