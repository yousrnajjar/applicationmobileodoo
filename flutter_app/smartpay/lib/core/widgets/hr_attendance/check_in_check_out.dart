
import 'package:flutter/material.dart';
import 'package:smartpay/ir/models/employee.dart';

import 'ci_co_form_with_picture_and_pos.dart';
import 'employee_check_in_check_out.dart';



class CheckInCheckOut extends StatefulWidget {
  final EmployeeAllInfo employee;

  const CheckInCheckOut({
    super.key,
    required this.employee,
  });

  @override
  State<CheckInCheckOut> createState() => _CheckInCheckOutState();
}

class _CheckInCheckOutState extends State<CheckInCheckOut> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmployeeCheckInCheckOut(
          employee: widget.employee,
        ),
        Expanded(
          child: CheckInCheckOutFormWithPicture(employee: widget.employee)
        ),
      ],
    );
  }
}

// Path: check_in_check_out_form.dart
