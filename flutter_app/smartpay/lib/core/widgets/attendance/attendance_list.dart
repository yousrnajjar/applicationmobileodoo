import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/core/widgets/attendance/attendance_list_item.dart';
import 'package:smartpay/ir/models/attendance_models.dart';

class AttendanceList extends ConsumerStatefulWidget {
  final List<Attendance> list; 
  const AttendanceList({super.key, required  this.list});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AttendanceListState();
  }
}

class _AttendanceListState extends ConsumerState<AttendanceList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: (widget.list.isEmpty)
          ? Center(
              child: Text(
                "Aucune présence!",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              itemCount: widget.list.length,
              itemBuilder: (context, index) => Dismissible(
                  key: ValueKey(index),
                  child: AttendanceItem(attendance: widget.list[index])),
            ),
    );
  }
}
