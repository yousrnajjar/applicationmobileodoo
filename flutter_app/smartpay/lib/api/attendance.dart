import 'package:smartpay/api/auth/session.dart';

class Attendance {
  int? id;
  List<dynamic>? employeeId;
  List<dynamic>? departmentId;
  dynamic checkIn;
  dynamic checkOut;
  double? workedHours;
  String? displayName;
  List? createUid;
  String? createDate;
  List? writeUid;
  String? writeDate;
  String? sLastUpdate;

  Attendance(
      {this.id,
      this.employeeId,
      this.departmentId,
      this.checkIn,
      this.checkOut,
      this.workedHours,
      this.displayName,
      this.createUid,
      this.createDate,
      this.writeUid,
      this.writeDate,
      this.sLastUpdate});

  Attendance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    employeeId = json['employee_id'];
    departmentId = json['department_id'];
    checkIn = json['check_in'];
    checkOut = json['check_out'];
    workedHours = json['worked_hours'];
    displayName = json['display_name'];
    createUid = json['create_uid'];
    createDate = json['create_date'];
    writeUid = json['write_uid'];
    writeDate = json['write_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['employee_id'] = employeeId;
    data['department_id'] = departmentId;
    data['check_in'] = checkIn;
    data['check_out'] = checkOut;
    data['worked_hours'] = workedHours;
    data['display_name'] = displayName;
    data['create_uid'] = createUid;
    data['create_date'] = createDate;
    data['write_uid'] = writeUid;
    data['write_date'] = writeDate;
    return data;
  }

  String getEmployeeImageUrl(String baseUrl) {
    return "$baseUrl/web/image?model=hr.employee&id=${employeeId![0]}&field=image_128";
  }

}

class EmployeeAttendanceInfo {
  final int id;
  final String attendanceState;
  final String name;
  final double hoursToday;
  final Map<String, dynamic> dataJson;
  List<Attendance> attendances = [];

  EmployeeAttendanceInfo({
    required this.id,
    required this.attendanceState,
    required this.name,
    required this.hoursToday,
  }) : dataJson = {};

  EmployeeAttendanceInfo.fromJSON(data)
      : id = data['id'],
        attendanceState = data["attendance_state"],
        name = data['name'],
        hoursToday = data["hours_today"],
        dataJson = data;

  EmployeeAttendanceInfo.empty()
      : id = -1,
        attendanceState = "",
        name = "",
        hoursToday = -1,
        dataJson = {};
}

class AttendanceAPI {
  final Session session;

  AttendanceAPI(this.session);

  Future<EmployeeAttendanceInfo> getInfo(int uid) async {
    var data = {
      "model": "hr.employee",
      "method": "search_read",
      "args": [
        [
          ["user_id", "=", uid]
        ],
        ["attendance_state", "name", "hours_today"]
      ],
      "kwargs": {}
    };
    var result = await session.callKw(data) as List;

    return EmployeeAttendanceInfo.fromJSON(result[0]);
  }

  Future<EmployeeAttendanceInfo> updateAttendance(int id) async {
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
    var attendanceInfo = EmployeeAttendanceInfo(
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
