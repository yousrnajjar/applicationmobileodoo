import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/attendance.dart';

import 'attendance_list_item.dart';

class AttendanceList extends StatefulWidget {
  final int employeeId;
  const AttendanceList({super.key, required  this.employeeId});

  @override
  State<AttendanceList> createState() {
    return _AttendanceListState();
  }
}

class _AttendanceListState extends State<AttendanceList> {

  Future<List<Attendance>> _getAttendances() async {
    if (kDebugMode) {
      print("AttendanceList _getAttendances: ${widget.employeeId}");
    }
    var daysDelta = await attendanceCreatedDaysDelta();
    DateTime utcDate2MonthBefore =
        DateTime.now().subtract(Duration(days: daysDelta));

    var attendanceData = await OdooModel("hr.attendance").searchRead(
      domain: [
        ["employee_id", "=", widget.employeeId],
        ['create_date', '>', dateFormatter.format(utcDate2MonthBefore)]
      ],
      fieldNames: ["employee_id", "check_in", "check_out", "worked_hours"],
    );
    if (kDebugMode) {
      print("AttendanceList _getAttendances: $attendanceData");
    }
    return attendanceData
        .map<Attendance>((json) => Attendance.fromJson(json))
        .toList();
  }

  Future<int> attendanceCreatedDaysDelta() async {
    try {
      var fieldNames = ['key', 'value'];
      var domain = [
        [
          'key',
          'in',
          ['mobile_hr_attentance_auto.app_attendance_created_days_difference']
        ]
      ];
      var response = await OdooModel('ir.config_parameter')
          .searchRead(domain: domain, order: 'id desc', fieldNames: fieldNames);
      if (kDebugMode) {
        print(response);
      }
      return int.parse(response[0]['value']);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<List<Attendance>>(
        future: _getAttendances(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return AttendanceItem(attendance: snapshot.data![index]);
              },
            );
          } else if (snapshot.hasError) {
            if (kDebugMode) {
              print("AttendanceList error: ${snapshot.error}");
            }
            return Center(
              child: Text(
                "Erreur lors du chargement des données",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
