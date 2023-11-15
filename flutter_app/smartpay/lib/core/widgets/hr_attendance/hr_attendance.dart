import 'dart:convert';
import 'dart:io';

import 'package:cross_file/src/types/interface.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/check_in_check_out_state.dart';

var dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
var dateFormatter = DateFormat('yyyy-MM-dd');
var timeFormatter = DateFormat('HH:mm:ss');

class HrAttendance {
  final int employeeId;

  const HrAttendance(this.employeeId);

  static OdooModel odooModel = OdooModel("hr.attendance");

  /// attendanceFields
  static List<String> attendanceFields = [
    'id',
    'employee_id',
    'check_in',
    'check_out',
    'worked_hours',
  ];

  /// get Latest Attendance
  Future<Map<String, dynamic>> getLatestAttendance() async {
    List<Map<String, dynamic>> response;
    try {
      // Récupérer la dernière entrée de pointage de l'employé
      response = await odooModel.searchRead(domain: [
        ["employee_id", "=", employeeId]
      ], fieldNames: attendanceFields, limit: 1);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
    if (response.isEmpty) {
      return {};
    }
    return response[0];
  }

  /// Update attendance with check out
  Future<List<Map<String, dynamic>>> _updateAttendance(int attendanceId) async {
    try {
      var res = await OdooModel.session.write("hr.attendance", [attendanceId],
          {'check_out': dateTimeFormatter.format(DateTime.now().toUtc())});
      if (!res) {
        return [];
      }
      // Récupérer la dernière entrée de pointage de l'employé qui n'a pas de pointage de sortie
      // Récupérer le pointage
      return await OdooModel("hr.attendance").searchRead(
        domain: [
          ["id", "=", attendanceId]
        ],
        fieldNames: attendanceFields,
        limit: 1,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  /// Get latest check in with no check out
  Future<List<Map<String, dynamic>>> _getLatestCheckInWithNoCheckOut() async {
    try {
      // Récupérer la dernière entrée de pointage de l'employé qui n'a pas de pointage de sortie
      return await OdooModel("hr.attendance").searchRead(
        domain: [
          ["employee_id", "=", employeeId],
          ["check_in", "!=", false],
          ["check_out", "=", false],
        ],
        fieldNames: attendanceFields,
        limit: 1,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  /// Get latest check in
  Future<List<Map<String, dynamic>>> _getLatestCheckIn() async {
    try {
      // Récupérer la dernière entrée de pointage de l'employé qui n'a pas de pointage de sortie
      return await OdooModel("hr.attendance").searchRead(
        domain: [
          ["employee_id", "=", employeeId],
          ["check_in", "!=", false],
        ],
        fieldNames: attendanceFields,
        limit: 1,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  /// Ccréer un pointage
  Future<List<Map<String, dynamic>>> _createAttendance(
      {bool withCkeck = true}) async {
    DateTime now = DateTime.now();
    try {
      var model = "hr.attendance";
      Map<String, dynamic> data = {
        "employee_id": employeeId,
      };
      if (withCkeck) {
        data["check_in"] = dateTimeFormatter.format(now.toUtc());
      }

      // Créer un pointage
      var id = await OdooModel.session.create(model, data);
      // Récupérer le pointage
      var list = await OdooModel("hr.attendance").searchRead(
        domain: [
          ["id", "=", id]
        ],
        fieldNames: attendanceFields,
        limit: 1,
      );
      return list;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  /// Get or create or update attendance
  /// Si l'employé n'a pas de pointage, il faut créer un pointage
  /// Si l'employé a un pointage, il faut le récupérer
  /// L'heure de pointage est l'heure actuelle
  Future<List<Map<String, dynamic>>> _getOrCreateOrUpdateAttendance() async {
    // Récupérer la dernière entrée de pointage de l'employé qui n'a pas de pointage de sortie
    List<Map<String, dynamic>> response =
        await _getLatestCheckInWithNoCheckOut();
    List<Map<String, dynamic>> result = [];
    if (response.isEmpty) {
      if (kDebugMode) {
        print("No attendance");
      }
      // Si l'employé n'a pas de pointage, il faut créer un pointage
      response = await _createAttendance();
    } else {
      if (kDebugMode) {
        print("Attendance ${response[0]['id']}");
      }
      // Si l'employé a un pointage, il faut faire une mise à jour
      var attendanceId = response[0]['id'];
      result = await _updateAttendance(attendanceId);
    }
    return result;
  }

  ///Checkin, Checkout
  Future<Map<String, dynamic>> _check() async {
    Map<String, dynamic> attendance;
    List<Map<String, dynamic>> attendances;
    try {
      attendances = await _getOrCreateOrUpdateAttendance();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
    if (attendances.isEmpty) {
      return {};
    } else {
      attendance = attendances[0];
    }

    DateTime? day;
    DateTime? checkIn;
    DateTime? checkOut;
    Duration? workedHours;
    try {
      //var checkIn = DateTime.parse(attendance['check_in']);
      checkIn = attendance['check_in'] != false
          ? OdooModel.session
              .toLocalTime(dateTimeFormatter.parse(attendance['check_in']))
          : null;
      //var checkOut = attendance['check_out'] != false ? DateTime.parse(attendance['check_out']) : null;
      checkOut = attendance['check_out'] != false
          ? OdooModel.session
              .toLocalTime(dateTimeFormatter.parse(attendance['check_out']))
          : null;
      day = checkIn != null
          ? dateFormatter.parse(dateFormatter.format(checkIn))
          : null;

      double hoursRaw = attendance['worked_hours'] != false
          ? attendance['worked_hours']
          : 0.0;

      workedHours = Duration(
          hours: hoursRaw.floor(),
          minutes: ((hoursRaw - hoursRaw.floor()) * 60).floor(),
          seconds: hoursRaw.floor() * 3600);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }

    return {
      "id": attendance["id"],
      //'success': true,
      'day': day,
      'startTime': checkIn,
      'endTime': checkOut,
      //'state: state,
      'workTime': workedHours,
    };
  }

  static Future<List<Duration>> _getWorkingTimeInterval() async {
    List<Map<String, dynamic>> response;
    try {
      var fieldNames = ['key', 'value'];
      var domain = [
        [
          'key',
          'in',
          [
            'mobile_hr_attentance_auto.work_end_time',
            'mobile_hr_attentance_auto.work_start_time'
          ]
        ]
      ];
      response = await OdooModel('ir.config_parameter')
          .searchRead(domain: domain, order: 'id desc', fieldNames: fieldNames);
      if (kDebugMode) {
        print(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return [const Duration(hours: 8), const Duration(hours: 17)];
    }
    if (response.isEmpty) {
      return [const Duration(hours: 8), const Duration(hours: 17)];
    }
    var timeStart = response.firstWhere((element) =>
        element['key'] == 'mobile_hr_attentance_auto.work_start_time')['value'];
    var timeEnd = response.firstWhere((element) =>
        element['key'] == 'mobile_hr_attentance_auto.work_end_time')['value'];
    return [
      Duration(
        hours: int.parse(timeStart.split(":")[0]),
        minutes: int.parse(timeStart.split(":")[1]),
        seconds: int.parse(timeStart.split(":")[2]),
      ),
      Duration(
        hours: int.parse(timeEnd.split(":")[0]),
        minutes: int.parse(timeEnd.split(":")[1]),
        seconds: int.parse(timeEnd.split(":")[2]),
      ),
    ];
  }

  Future<Map<String, dynamic>> _getCheckInCheckOutInfo() async {
    bool isWorkingHour = await isWorkingHours();
    Map<String, dynamic> response;
    try {
      response = await getLatestAttendance();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {
        //'success': true,
        'workTime': null,
        'day': null,
        'startTime': null,
        'endTime': null,
        'state': isWorkingHour
            ? CheckInCheckOutState.canCheckIn
            : CheckInCheckOutState.hourNotReached
      };
    }
    if (response.isEmpty) {
      return {
        //'success': true,
        'workTime': null,
        'day': DateTime.now(),
        'startTime': null,
        'endTime': null,
        'state': isWorkingHour
            ? CheckInCheckOutState.canCheckIn
            : CheckInCheckOutState.hourNotReached
      };
    }
    var attendance = response;
    CheckInCheckOutState? state;
    DateTime? day = attendance['check_in'] != false
        ? OdooModel.session
            .toLocalTime(dateTimeFormatter.parse(attendance['check_in']))
        : null;
    DateTime? startTime = attendance['check_in'] != false
        ? OdooModel.session
            .toLocalTime(dateTimeFormatter.parse(attendance['check_in']))
        : null;
    DateTime? endTime = attendance['check_out'] != false
        ? OdooModel.session
            .toLocalTime(dateTimeFormatter.parse(attendance['check_out']))
        : null;

    // DateTime? endTime = attendance['check_out'] != false
    //     ? dateTimeFormatter.parse(attendance['check_out'])
    //     : null;
    Duration workTime = getWorkingHours(attendance);

    var now = DateTime.now();
    print('now: $now, day: $day');
    // if current time in 08:00 - 18:00
    if (!isWorkingHour) {
      state = CheckInCheckOutState.hourNotReached;
    } else if (attendance['check_out'] == false) {
      state = CheckInCheckOutState.canCheckOut;
    } else if (attendance['check_out'] != false &&
        attendance['check_in'] != false &&
        day!.year == now.year &&
        day.month == now.month &&
        day.day == now.day) {
      state = CheckInCheckOutState.hourNotReached;
    } else {
      state = CheckInCheckOutState.canCheckIn;
    }

    return {
      //'success': true,
      'workTime': workTime,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'state': state
    };
  }

  static Future<bool> isWorkingHours() async {
    var workingInterval = await _getWorkingTimeInterval();
    var hourStartDay = workingInterval[0];
    var hourEndDay = workingInterval[1];
    DateTime now = DateTime.now();
    bool isWorkingHour =
        (now.hour >= hourStartDay.inHours && now.hour <= hourEndDay.inHours);
    return isWorkingHour;
  }

  static Duration getWorkingHours(Map<String, dynamic> attendance) {
    DateTime? startTime = attendance['check_in'] != false
        ? OdooModel.session
            .toLocalTime(dateTimeFormatter.parse(attendance['check_in']))
        : null;
    Duration workTime;
    if (attendance['check_out'] != false) {
      double hoursRaw = attendance['worked_hours'] != false
          ? attendance['worked_hours']
          : 0.0;
      var hours = hoursRaw.floor();
      var minutesRaw = (hoursRaw - hours) * 60;
      var minutes = minutesRaw.floor();
      workTime = Duration(
          hours: hours,
          minutes: minutes,
          seconds: ((minutesRaw - minutes) * 60).floor());
    } else {
      DateTime now = DateTime.now();
      workTime = Duration(
        hours: now.hour - startTime!.hour,
        minutes: now.minute - startTime.minute,
        seconds: now.second - startTime.second,
      );
    }
    return workTime;
  }

  Future<Map<String, dynamic>> getOrCheck({bool check = false}) async {
    if (check) {
      return _check();
    } else {
      return _getCheckInCheckOutInfo();
    }
  }

  Future<void> addImageAndPosition(Uint8List imageBytes, Position position,
      {bool isCheckOut = false}) async {
    List<Map<String, dynamic>> atts = [];
    Map<String, dynamic> data = {};
    if (!isCheckOut) {
      atts = await _getLatestCheckInWithNoCheckOut();
      data = {
        'check_in_image': base64Encode(imageBytes),
        'check_in_geo_latitude': position.latitude,
        'check_in_geo_longitude': position.longitude,
        'check_in_geo_altitude': position.altitude,
        'check_in_geo_accuracy': position.accuracy,
        'check_in_geo_time': dateTimeFormatter
            .format(position.timestamp ?? DateTime.now().toUtc()),
      };
    } else {
      atts = await _getLatestCheckIn();
      data = {
        'check_out_image': base64Encode(imageBytes),
        'check_out_geo_latitude': position.latitude,
        'check_out_geo_longitude': position.longitude,
        'check_out_geo_altitude': position.altitude,
        'check_out_geo_accuracy': position.accuracy,
        'check_out_geo_time': dateTimeFormatter
            .format(position.timestamp ?? DateTime.now().toUtc()),
      };
    }
    //atts = await _getLatestCheckInWithNoCheckOut();
    var res = await OdooModel.session.write(
      "hr.attendance",
      [atts[0]['id']],
      data,
    );
  }
}
