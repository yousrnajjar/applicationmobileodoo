import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/session.dart';
import 'package:smartpay/core/providers/session_providers.dart';
import 'package:smartpay/ir/models/attendance_models.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:smartpay/providers/employee_list_providers.dart';

class AttendanceItem extends ConsumerWidget {
  final Attendance attendance;

  const AttendanceItem({super.key, required this.attendance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Session session = ref.watch(sessionProvider);
    var employee = ref
        .watch(employeesProvider)
        .firstWhere((emp) => attendance.employeeId![0] == emp.id);
    ThemeData theme = Theme.of(context);
    var smallText = titleVerySmall(theme);
    var titleLarge = titleLargeBold(theme);
    return ListTile(
      leading: employee.imageFrom(session.url!),
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
      trailing: Text(attendance.workedHours!.toStringAsFixed(3)),
    );
  }
}
