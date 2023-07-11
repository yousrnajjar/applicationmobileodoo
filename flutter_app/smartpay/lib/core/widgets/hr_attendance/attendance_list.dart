import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/ir/models/attendance.dart';
import 'package:smartpay/ir/model.dart';

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
    var attendanceData = await OdooModel("hr.attendance").searchRead(
      domain: [
        ["employee_id", "=", widget.employeeId]
      ],
      fieldNames: ["employee_id", "check_in", "check_out", "worked_hours"],
    );
    if (kDebugMode) {
      print("AttendanceList _getAttendances: $attendanceData");
    }
    return attendanceData.map<Attendance>((json) => Attendance.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    //return Container(
      //padding: const EdgeInsets.all(10),
      //child: (widget.list.isEmpty)
          //? Center(
              //child: Text(
                //"Aucune présence!",
                //style: Theme.of(context).textTheme.bodyLarge,
              //),
            //)
          //: ListView.builder(
              //itemCount: widget.list.length,
              //itemBuilder: (context, index) => Dismissible(
                  //key: ValueKey(index),
                  //child: AttendanceItem(attendance: widget.list[index])),
            //),
    //);
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
