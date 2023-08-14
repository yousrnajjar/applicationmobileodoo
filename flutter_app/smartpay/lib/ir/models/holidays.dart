import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';

class HolidayType {
  final Map<String, dynamic> data;

  HolidayType(this.data);

  get id => data["id"] ?? -1;

  String get name {
    return data["name"] ?? "Sans nom";
  }
}

final dayFormatter = DateFormat('yyyy-MM-dd');

// TODO: Extend Model Helper
class Holiday {
  Holiday();

  static List<String> displayFieldNames = [
    'request_date_from',
    'request_date_to',
    'holiday_status_id',
    'notes',
    'number_of_days',
  ];
  
  List<String> get editableFields => [
    'request_date_from',
    'request_date_to',
    'holiday_status_id',
    'notes',
    'number_of_days',
  ];

  ///
  static List<String> defaultFields = [
    //'id',
    'can_reset',
    'can_approve',
    'state',
    'tz',
    'tz_mismatch',
    'holiday_type',
    'leave_type_request_unit',
    'display_name',
    'holiday_status_id',
    'date_from',
    'date_to',
    'payslip_status',
    'request_date_from',
    'request_date_to',
    'request_date_from_period',
    'request_unit_half',
    'request_unit_hours',
    'request_unit_custom',
    'request_hour_from',
    'request_hour_to',
    'number_of_days_display',
    'number_of_days',
    'number_of_hours_display',
    'user_id',
    'employee_id',
    'department_id',
    'name',
    'notes',
    //'message_follower_ids',
    //'activity_ids',
    //'message_ids',
    //'message_attachment_count'
  ];

  static List<String> allFields = [
    ...defaultFields,
    'duration_display',
    'id',
    /*"message_follower_ids",
    "activity_ids",
    "message_ids",
    "message_attachment_count"*/
  ];
  int? id;
  dynamic canApprove;
  dynamic canReset;
  dynamic state;
  dynamic tz;
  dynamic tzMismatch;
  dynamic holidayType;
  dynamic leaveTypeRequestUnit;
  dynamic displayName;
  dynamic holidayStatusId;
  dynamic dateFrom;
  dynamic dateTo;
  dynamic durationDisplay;
  dynamic payslipStatus;
  dynamic requestDateFrom;
  dynamic requestDateTo;
  dynamic requestDateFromPeriod;
  dynamic requestUnitHalf;
  dynamic requestUnitHours;
  dynamic requestUnitCustom;
  dynamic requestHourFrom;
  dynamic requestHourTo;
  dynamic numberOfDaysDisplay;
  dynamic numberOfDays;
  dynamic numberOfHoursDisplay;
  dynamic userId;
  dynamic employeeId;
  dynamic departmentId;
  dynamic name;
  dynamic notes;

  /// Onchange spec for hr.leave
  static Map<String, String> onchangeSpec = {
    'can_reset': '',
    'can_approve': '',
    'state': '1',
    'tz': '1',
    'tz_mismatch': '',
    'holiday_type': '1',
    'leave_type_request_unit': '',
    'display_name': '',
    'holiday_status_id': '1',
    'date_from': '1',
    'date_to': '1',
    'request_date_from': '1',
    'request_date_to': '1',
    'request_date_from_period': '1',
    'request_unit_half': '1',
    'request_unit_hours': '1',
    'request_unit_custom': '1',
    'request_hour_from': '1',
    'request_hour_to': '1',
    'number_of_days_display': '',
    'number_of_days': '1',
    'number_of_hours_display': '',
    'user_id': '',
    'employee_id': '1',
    'department_id': '1',
    'name': '1',
    'message_follower_ids': '',
    'activity_ids': '',
    'message_ids': '',
    'message_attachment_count': ''
  };

  Holiday.fromJSON(Map<String, dynamic> data) {
    id = data["id"];
    canApprove = data["can_approve"];
    canReset = data["can_reset"];
    state = data["state"];
    tz = data["tz"];
    tzMismatch = data["tz_mismatch"];
    holidayType = data["holiday_type"];
    leaveTypeRequestUnit = data["leave_type_request_unit"];
    displayName = data["display_name"];
    holidayStatusId = data["holiday_status_id"];
    dateFrom = data["date_from"];
    dateTo = data["date_to"];
    durationDisplay = data["duration_display"];
    payslipStatus = data["payslip_status"];
    requestDateFrom = data["request_date_from"];
    requestDateTo = data["request_date_to"];
    requestDateFromPeriod = data["request_date_from_period"];
    requestUnitHalf = data["request_unit_half"];
    requestUnitHours = data["request_unit_hours"];
    requestUnitCustom = data["request_unit_custom"];
    requestHourFrom = data["request_hour_from"];
    requestHourTo = data["request_hour_to"];
    numberOfDaysDisplay = data["number_of_days_display"];
    numberOfDays = data["number_of_days"];
    numberOfHoursDisplay = data["number_of_hours_display"];
    userId = data["user_id"];
    employeeId = data["employee_id"];
    departmentId = data["department_id"];
    name = data["name"];
    notes = data["notes"];
    //messageFollowerIds = data["message_follower_ids"];
    //activityIds = data["activity_ids"];
    //messageIds = data["message_ids"];
    //messageAttachmentCount = data["message_attachment_count"];

    /*id = data["id"];
    state = data["state"];
    holidayStatusId = data["holiday_status_id"];
    name = data["name"];
    dateFrom = data["date_from"];
    dateTo = data["date_to"];
    durationDisplay = data["duration_display"];
    payslipStatus = data["payslip_status"];
    employeeId = data["employee_id"];
    userId = data["user_id"];*/
  }
  static Map<String, Color> stateColors = {
    'validate': kLightGreen,
    'refuse': kLightOrange,
    'confirm': kLightPink,
  };

  static Map<String, Color> stateTextColors = {
    'validate': kGreen,
    'refuse': Colors.redAccent,
    'confirm': kGrey,
  };
  Color get color {
    if (kDebugMode) {
      print("================$state");
    }
    return stateTextColors[state] ?? Colors.black;
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data["id"] = id;
    data["can_approve"] = canApprove;
    data["can_reset"] = canReset;
    data["state"] = state;
    data["tz"] = tz;
    data["tz_mismatch"] = tzMismatch;
    data["holiday_type"] = holidayType;
    data["leave_type_request_unit"] = leaveTypeRequestUnit;
    data["display_name"] = displayName;
    data["holiday_status_id"] = holidayStatusId;
    data["date_from"] = dateFrom;
    data["date_to"] = dateTo;
    data["duration_display"] = durationDisplay;
    data["payslip_status"] = payslipStatus;
    data["request_date_from"] = requestDateFrom;
    data["request_date_to"] = requestDateTo;
    data["request_date_from_period"] = requestDateFromPeriod;
    data["request_unit_half"] = requestUnitHalf;
    data["request_unit_hours"] = requestUnitHours;
    data["request_unit_custom"] = requestUnitCustom;
    data["request_hour_from"] = requestHourFrom;
    data["request_hour_to"] = requestHourTo;
    data["number_of_days_display"] = numberOfDaysDisplay;
    data["number_of_days"] = numberOfDays;
    data["number_of_hours_display"] = numberOfHoursDisplay;
    data["user_id"] = userId;
    data["employee_id"] = employeeId;
    data["department_id"] = departmentId;
    data["name"] = name;
    data["notes"] = notes;
    //data["message_follower_ids"] = messageFollowerIds;
    //data["activity_ids"] = activityIds;
    //data["message_ids"] = messageIds;
    //data["message_attachment_count"] = messageAttachmentCount;

    return data;
  }

  static Holiday empty() {
    /// Initialize with an empty value
    return Holiday.fromJSON({});
  }

  DateTime? get from {
    return dayFormatter.parse(dateFrom);
  }

  DateTime? get to {
    return dayFormatter.parse(dateTo);
  }

  /// Group a list of [Holiday] by [Holiday.status]
  static Map<String, List<Holiday>> groupByStatus(List<Holiday> holidays) {
    var map = <String, List<Holiday>>{};
    for (var holiday in holidays) {
      var status = holiday.state;
      if (map.containsKey(status)) {
        map[status]!.add(holiday);
      } else {
        map[status] = [holiday];
      }
    }
    return map;
  }

  static Future<bool> validate(int id) async {
    return await OdooModel.session.callKw({
      "model": "hr.leave",
      "method": "action_validate",
      "args": [
        [id]
      ],
      "kwargs": {}
    });
  }

  static Future<bool> refuse(int id) async {
    return await OdooModel.session.callKw({
      "model": "hr.leave",
      "method": "action_refuse",
      "args": [
        [id]
      ],
      "kwargs": {}
    });
  }
}
