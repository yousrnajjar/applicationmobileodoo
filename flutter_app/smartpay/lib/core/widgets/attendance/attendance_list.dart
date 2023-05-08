import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/core/widgets/attendance/attendance_list_item.dart';
import 'package:smartpay/providers/attendance_list_providers.dart';
import 'package:smartpay/providers/employee_list_providers.dart';

class AttendanceList extends ConsumerStatefulWidget {
  const AttendanceList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AttendanceListState();
  }
}

class _AttendanceListState extends ConsumerState<AttendanceList> {
  @override
  Widget build(BuildContext context) {
    var attendances = ref.watch(attendancesProvider);
    return Container(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: attendances.length,
        itemBuilder: (context, index) => Dismissible(
            key: ValueKey(index),
            child: AttendanceItem(attendance: attendances[index])),
      ),
    );
  }
}
