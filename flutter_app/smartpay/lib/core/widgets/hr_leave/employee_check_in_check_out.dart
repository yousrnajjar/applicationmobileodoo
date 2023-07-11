import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/hr_employee/hr_employee_card_detail.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/employee.dart';

class EmployeeCheckInCheckOut extends StatefulWidget {
  final EmployeeAllInfo employee;

  const EmployeeCheckInCheckOut({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeCheckInCheckOut> createState() =>
      _EmployeeCheckInCheckOutState();
}

class _EmployeeCheckInCheckOutState extends State<EmployeeCheckInCheckOut> {
  Future<List<Map<OdooField, dynamic>>> _loadEmployeeInfo() {
    return OdooModel('hr.employee').searchReadAsOdooField(
      domain: [
        ['id', '=', widget.employee.id]
      ],
      fieldNames: ['name', 'job_id', 'image_128'],
      limit: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    //return EmployeeCard(employee: widget.employee);
    return FutureBuilder(
      future: _loadEmployeeInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Text(
                'Désolé vos informations ne sont pas disponibles');
          }
          return EmployeeCard(
            employee: snapshot.data![0],
            showDetails: false,
          );
        } else {
          return const Text('Loading...');
        }
      },
    );
  }
}
