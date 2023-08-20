import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/check_in_check_out_state.dart';

var dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
var dateFormatter = DateFormat('yyyy-MM-dd');
var timeFormatter = DateFormat('HH:mm:ss');

class HrAttendance {
  final int employeeId;

  const HrAttendance(this.employeeId);

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
      response = await OdooModel("hr.attendance").searchRead(domain: [
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
    DateTime now = OdooModel.session.toServerTime(DateTime.now());
    try {
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

  /// Ccréer un pointage
  Future<List<Map<String, dynamic>>> _createAttendance(
      {bool withCkeck = true}) async {
    DateTime now = OdooModel.session.toServerTime(DateTime.now());
    try {
      var model = "hr.attendance";
      Map<String, dynamic> data = {
        "employee_id": employeeId,
      };
      if (withCkeck) {
        data["check_in"] = dateTimeFormatter.format(now);
      }

      // Créer un pointage
      var id = await OdooModel.session.create(model, data);
      // Récupérer le pointage
      return await OdooModel("hr.attendance").searchRead(
        domain: [
          ["id", "=", id]
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

  /// Get or create or update attendance
  /// Si l'employé n'a pas de pointage, il faut créer un pointage
  /// Si l'employé a un pointage, il faut le récupérer
  /// L'heure de pointage est l'heure actuelle
  Future<Map<String, dynamic>> _getOrCreateOrUpdateAttendance() async {
    // Récupérer la dernière entrée de pointage de l'employé qui n'a pas de pointage de sortie
    List<Map<String, dynamic>> response =
        await _getLatestCheckInWithNoCheckOut();

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
      response = await _updateAttendance(attendanceId);
    }
    return response[0];
  }

  ///Checkin, Checkout
  Future<Map<String, dynamic>> _check() async {
    Map<String, dynamic> attendance;
    try {
      attendance = await _getOrCreateOrUpdateAttendance();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
    DateTime? day;
    DateTime? checkIn;
    DateTime? checkOut;
    Duration? workedHours;
    try {
      //var checkIn = DateTime.parse(attendance['check_in']);
      checkIn = attendance['check_in'] != false
          ? dateTimeFormatter.parse(attendance['check_in'])
          : null;
      //var checkOut = attendance['check_out'] != false ? DateTime.parse(attendance['check_out']) : null;
      checkOut = attendance['check_out'] != false
          ? dateTimeFormatter.parse(attendance['check_out'])
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
      var fieldNames = ['work_start_time', 'work_end_time'];
      response = await OdooModel('res.config.settings').searchRead(
          domain: [], order: 'id desc', fieldNames: fieldNames, limit: 1);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return [const Duration(hours: 8), const Duration(hours: 17)];
    }
    var timeStart = response[0]['work_start_time'];
    var timeEnd = response[0]['work_end_time'];
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
            ? CheckInCheckOutFormState.canCheckIn
            : CheckInCheckOutFormState.hourNotReached
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
            ? CheckInCheckOutFormState.canCheckIn
            : CheckInCheckOutFormState.hourNotReached
      };
    }
    var attendance = response;
    CheckInCheckOutFormState? state;
    DateTime? day = attendance['check_in'] != false
        ? dateFormatter.parse(attendance['check_in'])
        : null;

    DateTime? startTime = attendance['check_in'] != false
        ? dateTimeFormatter.parse(attendance['check_in'])
        : null;
    DateTime? endTime = attendance['check_out'] != false
        ? dateTimeFormatter.parse(attendance['check_out'])
        : null;

    // DateTime? endTime = attendance['check_out'] != false
    //     ? dateTimeFormatter.parse(attendance['check_out'])
    //     : null;
    Duration workTime = getWorkingHours(attendance);

    // if current time in 08:00 - 18:00
    if (!isWorkingHour) {
      state = CheckInCheckOutFormState.hourNotReached;
    } else if (attendance['check_out'] == false) {
      state = CheckInCheckOutFormState.canCheckOut;
    } else if (attendance['check_out'] != false &&
        attendance['check_in'] != false) {
      state = CheckInCheckOutFormState.hourNotReached;
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
    DateTime now = OdooModel.session.toServerTime(DateTime.now());
    bool isWorkingHour =
        (now.hour >= hourStartDay.inHours && now.hour <= hourEndDay.inHours);
    return isWorkingHour;
  }

  static Duration getWorkingHours(Map<String, dynamic> attendance) {
    DateTime? startTime = attendance['check_in'] != false
        ? dateTimeFormatter.parse(attendance['check_in'])
        : null;
    Duration workTime;
    if (attendance['check_out'] != false) {
      double hoursRaw = attendance['worked_hours'] != false
          ? attendance['worked_hours']
          : 0.0;
      workTime = Duration(
          hours: hoursRaw.floor(),
          minutes: ((hoursRaw - hoursRaw.floor()) * 60).floor(),
          seconds: hoursRaw.floor() * 3600);
    } else {
      DateTime now = OdooModel.session.toServerTime(DateTime.now());
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
}
