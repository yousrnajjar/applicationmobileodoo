import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/attendance.dart';
import 'package:smartpay/ir/model.dart';

import 'hr_attendance.dart';

var dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
var dateFormatter = DateFormat('yyyy-MM-dd');
var timeFormatter = DateFormat('HH:mm:ss');

String workedHourToPrettyString(Duration workedHour) {
  String hour = workedHour.inHours.toString().padLeft(2, '0');
  String minute = workedHour.inMinutes.remainder(60).toString().padLeft(2, '0');
  String second = workedHour.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (workedHour.inHours > 0) {
    return "$hour h $minute min $second s";
  } else if (workedHour.inMinutes > 0) {
    return "$minute min $second s";
  } else {
    return "$second s";
  }
}

class AttendanceItem extends StatelessWidget {
  
  final Attendance attendance;

  const AttendanceItem({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var smallText = titleVerySmall(theme);
    var titleLarge = titleLargeBold(theme);

    Duration workedHour = HrAttendance.getWorkingHours(attendance.toJson());
    String checkIn = "";
    if (attendance.checkIn != false) {
      String checkInString = attendance.checkIn!;
      DateTime checkInDateTime = dateTimeFormatter.parse(checkInString);
      checkInDateTime = OdooModel.session.toLocalTime(checkInDateTime);
      checkIn = dateTimeFormatter.format(checkInDateTime);
    }
    String checkOut = "";
    if (attendance.checkOut != false) {
      String checkOutString = attendance.checkOut!;
      DateTime checkOutDateTime = dateTimeFormatter.parse(checkOutString);
      checkOutDateTime = OdooModel.session.toLocalTime(checkOutDateTime);
      checkOut = dateTimeFormatter.format(checkOutDateTime);
    }
    return ListTile(
      leading: CircleAvatar(
        child: Text(attendance.employeeId![1].substring(0, 1)),
      ),
      title: Text(attendance.employeeId![1], style: titleLarge),
      subtitle: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("De ${checkIn}", style: smallText),
          if (attendance.checkOut != false)
            Text("À ${checkOut}", style: smallText)
        ],
      ),
      trailing: Text(
        workedHourToPrettyString(workedHour),
        style: titleLarge,
      ),
    );
  }

  Duration workingHours() {
    double? workedHourRaw = attendance.workedHours;
    Duration workedHour = (workedHourRaw != null)
        ? Duration(
            hours: workedHourRaw.toInt(),
            minutes: ((workedHourRaw - workedHourRaw.toInt()) * 60).toInt(),
            seconds: ((workedHourRaw - workedHourRaw.toInt()) * 3600).toInt(),
          )
        : const Duration(hours: 0, minutes: 0, seconds: 0);
    return workedHour;
  }
}
