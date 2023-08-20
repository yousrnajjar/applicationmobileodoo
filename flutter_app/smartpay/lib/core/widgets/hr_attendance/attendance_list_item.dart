import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/attendance.dart';

import 'hr_attendance.dart';

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

    return ListTile(
      leading: CircleAvatar(
        child: Text(attendance.employeeId![1].substring(0, 1)),
      ),
      title: Text(attendance.employeeId![1], style: titleLarge),
      subtitle: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("De ${attendance.checkIn}", style: smallText),
          if (attendance.checkOut != false)
            Text("À ${attendance.checkOut}", style: smallText)
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
