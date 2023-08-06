import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/check_in_check_out_state.dart';

// D2But et fin de journé
double HEURE_FIN_DE_JOURNE = 17.0;
double HEURE_DEBUT_DE_JOURNE = 8.0;

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
    try {
      // Récupérer la dernière entrée de pointage de l'employé
      var response = await OdooModel("hr.attendance").searchRead(domain: [
        ["employee_id", "=", employeeId]
      ], fieldNames: attendanceFields, limit: 1);
      return response[0];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  /// Update attendance with check out
  Future<List<Map<String, dynamic>>> _updateAttendance(int attendanceId) async {
    try {
      // Récupérer la dernière entrée de pointage de l'employé qui n'a pas de pointage de sortie
      var isUpdated = await OdooModel.session.write(
        "hr.attendance",
        [attendanceId],
        {
          "check_out": dateTimeFormatter.format(DateTime.now()),
        },
      );
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
      throw e;
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
      throw e;
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

  Future<Map<String, dynamic>> _getCheckInCheckOutInfo() async {
    Map<String, dynamic> response;
    DateTime now = DateTime.now();
    bool isWorkingHour =
        now.hour >= HEURE_DEBUT_DE_JOURNE && now.hour <= HEURE_FIN_DE_JOURNE;
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

    // DateTime? endTime = attendance['check_out'] != false
    //     ? dateTimeFormatter.parse(attendance['check_out'])
    //     : null;

    double hoursRaw =
        attendance['worked_hours'] != false ? attendance['worked_hours'] : 0.0;
    Duration workTime = Duration(
        hours: hoursRaw.floor(),
        minutes: ((hoursRaw - hoursRaw.floor()) * 60).floor(),
        seconds: hoursRaw.floor() * 3600);
    // if current time in 08:00 - 18:00
    if (!isWorkingHour) {
      state = CheckInCheckOutFormState.hourNotReached;
    } else if (attendance['check_out'] == false) {
      state = CheckInCheckOutFormState.canCheckOut;
    } else if (attendance['check_out'] != false &&
        attendance['check_in'] != false) {
      state = CheckInCheckOutFormState.canCheckIn;
    }

    return {
      //'success': true,
      'workTime': workTime,
      'day': day,
      'startTime': startTime,
      'state': state
    };
  }

  Future<Map<String, dynamic>> getOrCheck({bool check = false}) async {
    if (check) {
      return _check();
    } else {
      return _getCheckInCheckOutInfo();
    }
  }
}
