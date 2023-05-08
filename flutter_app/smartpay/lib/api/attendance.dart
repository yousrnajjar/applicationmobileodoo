import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/api/models.dart';

class AttendanceAPI {
  final Session session;

  AttendanceAPI(this.session);

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

  Future<Employee> getEmployee(int uid) async {
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

    return Employee.fromJSON(result[0]);
  }

  Future<Employee> updateAttendance(int id) async {
    var data = {
      "model": "hr.employee",
      "method": "attendance_manual",
      "args": [
        [id],
        "hr_attendance.hr_attendance_action_my_attendances"
      ],
      "kwargs": {}
    };
    var result = (await session.callKw(data));
    var attendance = Attendance.fromJson(result['action']['attendance']);
    bool isCheckOut = attendance.checkOut == false;
    String empName = attendance.employeeId![1];
    var attendanceInfo = Employee(
      id: attendance.employeeId![0],
      attendanceState: isCheckOut ? 'checked_in' : "checked_out",
      name: empName,
      hoursToday: result['action']['hours_today'],
    );
    return attendanceInfo;
  }

  Future<List<Attendance>> getAttentances(int uid) async {
    var data = {
      "model": "hr.attendance",
      "method": "search_read",
      "args": [
        [
          // ["user_id", "=", uid]
        ],
        ["employee_id", "check_in", "check_out", "worked_hours"]
      ],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;
    return [for (var res in result) Attendance.fromJson(res)];
  }
}
