import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/employee.dart';
import 'package:smartpay/ir/models/holidays.dart';

import '../model_helper.dart';

class User extends OdooModelHelper {
  EmployeeAllInfo? employee;
  Map<String, dynamic> employeeData = {};

  bool isAdmin = false;
  bool isManager = false;

  User(super.info);

  User.fromJson(super.info);

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  List<String> get allFields => [
        // Related Employee
        'employee_ids',
        // Company Employee
        'employee_id',
        // Manager
        'employee_parent_id',
        // Department
        "department_id",
        // User responsible of leaves approval.
        "leave_manager_id",
        // image 128
        "image_128",
        // if this contact is an Employee.
        'employee',
        // Used to log into system
        'id', 'name', 'login', 'display_name', 'gender', 'lang',
        'ref', 'vat',
        'function', 'job_title',
        'street', 'street2', 'zip', 'city', 'contact_address',

        // Check In, Check Out
        'last_check_in', 'last_check_out',
        // Allocation Used Display
        'allocation_used_display',
        // Allocation Display
        "allocation_display",
        // Total number of days off used
        'allocation_used_count'
            // Total number of days allocated.
            'allocation_count',

        // Attendance Status
        'attendance_state',

        // Hr Presence State
        'hr_presence_state',

        // color
        'color',
      ];

  @override
  List<String> get defaultFieldNames => [];

  @override
  List<String> get displayFieldNames => [];

  @override
  Map<String, String> get onchangeSpec => {};

  int get uid {
    if (!info.containsKey("uid") || info["uid"] == false) return -1;
    return info['uid'];
  }

  bool isAuthenticated() {
    return uid != -1;
    //return info.containsKey("uid") && (info["uid"] != null);
  }

  String getImageUrl(String baseUrl) {
    return "$baseUrl/web/image?model=res.users&id=$uid&field=image_128";
  }

  dynamic get employeeId {
    if (info.containsKey("employee_id") && info["employee_id"] != false) {
      return info['employee_id'];
    }
    return [];
  }

  List<int> get employeeIds {
    if (info.containsKey("employee_ids") && info["employee_ids"] != false) {
      return info['employee_ids'];
    }
    return [];
  }

  /// Return true if the employee atach to user has most than one subordinates.
  setIsManager() async {
    var subordinatesData = await OdooModel("hr.employee").searchRead(
      domain: [
        ['user_id', '=', uid]
      ],
      fieldNames: ['id', 'child_ids'],
    );
    if (subordinatesData.isNotEmpty) {
      for (var element in subordinatesData) {
        if (element['child_ids'].length > 0) {
          isManager = true;
          return;
        }
      }
    }
    isManager = false;
  }

  Future<List<Map<String, dynamic>>> getHolidayDetails(
      {bool onlyMe = false, required List<String> holidayFields}) async {
    
    var employeeIdManaged = <int>[info['employee_id'][0]];
    if (!onlyMe) {
      var subordinatesData = await OdooModel("hr.employee").searchRead(
        domain: [
          ['user_id', '=', uid]
        ],
        fieldNames: ['id', 'child_ids'],
      );
      if (subordinatesData.isNotEmpty) {
        for (var element in subordinatesData) {
          element['child_ids'].forEach((e) {
            employeeIdManaged.add(e);
          });
        }
      }
    }
    if (employeeIdManaged.isEmpty) {
      return [];
    }
    var data = await OdooModel("hr.leave").searchRead(
      domain: [
        ['employee_id', 'in', employeeIdManaged]
      ],
      fieldNames: holidayFields,
    );
    return data;
  }

  readEmployeeData() async {
    
    var list = await OdooModel("hr.employee").searchRead(domain: [
      ['user_id', '=', info[uid]]
    ]);
    employeeData = list[0];
  }

  getEmployeeData() {}
}
