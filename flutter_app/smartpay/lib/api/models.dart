import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

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

class Employee {
  final int id;
  final String attendanceState;
  final String name;
  final double hoursToday;
  final Map<String, dynamic> dataJson;
  List<Attendance> attendances = [];
  dynamic image_128;

  Employee({
    required this.id,
    required this.attendanceState,
    required this.name,
    required this.hoursToday,
  }) : dataJson = {};

  Employee.fromJSON(data)
      : id = data['id'],
        attendanceState = data["attendance_state"],
        name = data['name'],
        hoursToday = data["hours_today"],
        dataJson = data,
        image_128 = data['image_128'];

  Employee.empty()
      : id = -1,
        attendanceState = "",
        name = "",
        hoursToday = -1,
        dataJson = {};
}

class EmployeeAllInfo {
  int? id;
  dynamic name;
  List? userId;
  bool? active;
  dynamic privateEmail;
  dynamic gender;
  dynamic phone;
  dynamic departmentId;
  dynamic jobId;
  dynamic jobTitle;
  dynamic companyId;
  dynamic addressId;
  dynamic workPhone;
  dynamic mobilePhone;
  dynamic workEmail;
  dynamic workLocation;
  dynamic hrPresenceState;
  dynamic attendanceIds;
  dynamic lastAttendanceId;
  dynamic lastCheckIn;
  dynamic lastCheckOut;
  dynamic attendanceState;
  double? hoursLastMonth;
  double? hoursToday;
  dynamic hoursLastMonthDisplay;
  dynamic image_128;
  int? childAllCount;
  dynamic displayName;
  List? createUid;
  dynamic createDate;
  List? writeUid;
  dynamic writeDate;

  EmployeeAllInfo({
    this.id,
    this.name,
    this.userId,
    this.active,
    this.privateEmail,
    this.gender,
    this.phone,
    this.departmentId,
    this.jobId,
    this.jobTitle,
    this.companyId,
    this.addressId,
    this.workPhone,
    this.mobilePhone,
    this.workEmail,
    this.workLocation,
    this.hrPresenceState,
    this.attendanceIds,
    this.lastAttendanceId,
    this.lastCheckIn,
    this.lastCheckOut,
    this.attendanceState,
    this.hoursLastMonth,
    this.hoursToday,
    this.hoursLastMonthDisplay,
    this.childAllCount,
    this.displayName,
    this.createUid,
    this.createDate,
    this.writeUid,
    this.writeDate,
    this.image_128,
  });

  EmployeeAllInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    userId = json['user_id'] is bool ? [-1, ""] : json['user_id'];
    active = json['active'];
    privateEmail = json['private_email'];
    gender = json['gender'];
    phone = json['phone'];
    departmentId = json['department_id'];
    jobId = json['job_id'];
    jobTitle = json['job_title'];
    companyId = json['company_id'];
    addressId = json['address_id'];
    workPhone = json['work_phone'];
    mobilePhone = json['mobile_phone'];
    workEmail = json['work_email'];
    workLocation = json['work_location'];
    hrPresenceState = json['hr_presence_state'];
    attendanceIds = json['attendance_ids'];
    lastAttendanceId = json['last_attendance_id'];
    lastCheckIn = json['last_check_in'];
    lastCheckOut = json['last_check_out'];
    attendanceState = json['attendance_state'];
    hoursLastMonth = json['hours_last_month'];
    hoursToday = json['hours_today'];
    hoursLastMonthDisplay = json['hours_last_month_display'];
    childAllCount = json['child_all_count'];
    displayName = json['display_name'];
    createUid = json['create_uid'];
    createDate = json['create_date'];
    writeUid = json['write_uid'];
    writeDate = json['write_date'];
    image_128 = json["image_128"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['user_id'] = userId;
    data['active'] = active;
    data['private_email'] = privateEmail;
    data['gender'] = gender;
    data['phone'] = phone;
    data['department_id'] = departmentId;
    data['job_id'] = jobId;
    data['job_title'] = jobTitle;
    data['company_id'] = companyId;
    data['address_id'] = addressId;
    data['work_phone'] = workPhone;
    data['mobile_phone'] = mobilePhone;
    data['work_email'] = workEmail;
    data['work_location'] = workLocation;
    data['hr_presence_state'] = hrPresenceState;
    data['attendance_ids'] = attendanceIds;
    data['last_attendance_id'] = lastAttendanceId;
    data['last_check_in'] = lastCheckIn;
    data['last_check_out'] = lastCheckOut;
    data['attendance_state'] = attendanceState;
    data['hours_last_month'] = hoursLastMonth;
    data['hours_today'] = hoursToday;
    data['hours_last_month_display'] = hoursLastMonthDisplay;
    data['child_all_count'] = childAllCount;
    data['display_name'] = displayName;
    data['create_uid'] = createUid;
    data['create_date'] = createDate;
    data['write_uid'] = writeUid;
    data['write_date'] = writeDate;
    data['image_128'] = image_128;
    return data;
  }

  String getEmployeeImageUrl(String baseUrl) {
    return "$baseUrl/web/image?model=hr.employee&id=$id&field=image_128";
  }

  CircleAvatar imageFrom(String baseUrl) {
    return CircleAvatar(
      backgroundImage: FadeInImage(
        // Montre une placeholder quand l'image n'est pas disponible
        placeholder: MemoryImage(
          // Convertit des bytes en images
          kTransparentImage, // Cree une image transparente en bytes
        ),
        image: (image_128 != null)
            ? Image.memory(base64Decode(image_128)).image
            : NetworkImage(
                // Recupere une image par sont url
                getEmployeeImageUrl(baseUrl)),
        fit: BoxFit.contain,
        //height: 60,
        //width: 60,
      ).image,
    );
  }
}
