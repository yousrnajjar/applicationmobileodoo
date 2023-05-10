import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/api/employee/employee_api.dart';
import 'package:smartpay/api/models.dart';
import 'package:smartpay/providers/current_employee_provider.dart';
import 'package:smartpay/providers/models/user_info.dart';
import 'package:smartpay/providers/session_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final EmployeeAllInfo employee;
  const HomeScreen(
    this.employee, {
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeState();
  }
}

class _HomeState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Bienvenue ${widget.employee.name}"));
  }
}
