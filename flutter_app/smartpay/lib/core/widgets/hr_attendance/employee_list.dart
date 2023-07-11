import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/ir/models/employee.dart';

import 'employee_list_item.dart';

class EmployeeList extends ConsumerStatefulWidget {
  final List<EmployeeAllInfo> list;
  const EmployeeList({super.key, required  this.list});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EmployeeListState();
  }
}

class _EmployeeListState extends ConsumerState<EmployeeList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: (widget.list.isEmpty)
          ? const Center(
              child: Text("Aucun employé!"),
            )
          : ListView.builder(
              itemCount: widget.list.length,
              itemBuilder: (context, index) => Dismissible(
                  key: ValueKey(index),
                  child: EmployeeItem(employee: widget.list[index])),
            ),
    );
  }
}
