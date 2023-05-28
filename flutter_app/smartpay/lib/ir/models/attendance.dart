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