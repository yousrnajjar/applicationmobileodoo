import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/providers/employee_list_providers.dart';

import 'employee_list_item.dart';

class EmployeeList extends ConsumerStatefulWidget {
  const EmployeeList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EmployeeListState();
  }
}

class _EmployeeListState extends ConsumerState<EmployeeList> {
  @override
  Widget build(BuildContext context) {
    var employees = ref.watch(employeesProvider);
    return Container(
      padding: const EdgeInsets.all(10),
      child: (employees.isEmpty)
          ? const Center(
              child: Text("Aucun employé!"),
            )
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) => Dismissible(
                  key: ValueKey(index),
                  child: EmployeeItem(employee: employees[index])),
            ),
    );
  }
}
