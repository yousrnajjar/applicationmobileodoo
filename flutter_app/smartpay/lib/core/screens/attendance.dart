import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/attendance_models.dart';
import 'package:smartpay/core/widgets/attendance/attendance_list.dart';
import 'package:smartpay/core/widgets/attendance/check_in_out.dart';
import 'package:smartpay/core/widgets/attendance/employee_list.dart';
import 'package:smartpay/core/providers/user_info_providers.dart';

class InOutScreen extends ConsumerStatefulWidget {
  const InOutScreen({super.key});

  @override
  ConsumerState<InOutScreen> createState() => _InOutScreenState();
}

class _InOutScreenState extends ConsumerState<InOutScreen> {
  String _selectedPage = "in_out";
  Widget _activePage = const CheckInOut();
  int _selectedPageIndex = 0;
  List<EmployeeAllInfo> _employees = [];
  List<Attendance> _attendances = [];

  Future<void> _refresh() async {
    var user = ref.watch(userInfoProvider);
    if (_selectedPage == "in_out") {
      var employeeData = await OdooModel("hr.employee").searchRead(
        domain: [
          ['user_id', '=', user.uid]
        ],
        limit: 1,
      );
      user.employee = EmployeeAllInfo.fromJson(employeeData[0]);
    } else if (_selectedPage == 'attendance_list') {
      var attendancesData = await OdooModel("hr.attendance").searchRead(
        domain: [
          ['employee_id', '=', user.employee!.id]
        ],
        limit: 1000,
      );
      _attendances =
          attendancesData.map((e) => Attendance.fromJson(e)).toList();
      user.employee!.attendances = _attendances;
    } else if (_selectedPage == 'employee_list') {
      var employeesData = await OdooModel("hr.employee").searchRead(
        domain: [[]],
        limit: 1000,
      );
      _employees =
          employeesData.map((e) => EmployeeAllInfo.fromJson(e)).toList();
    }
    ref.read(userInfoProvider.notifier).setUserInfo(user);
  }

  Future<void> _selectPage(int index) async {
    if (index == 0) {
      _selectedPage = "in_out";
      await _refresh();
      setState(() {
        _activePage = const CheckInOut();
        _selectedPageIndex = 0;
      });
    } else if (index == 2) {
      _selectedPage = "attendance_list";
      await _refresh();
      setState(() {
        _activePage = AttendanceList(list: _attendances);
        _selectedPageIndex = 2;
      });
    } else if (index == 1) {
      _selectedPage = "employee_list";
      await _refresh();
      setState(() {
        _activePage = EmployeeList(list: _employees);
        _selectedPageIndex = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _refresh();
    return Scaffold(
      appBar: AppBar(title: const Text("Présence"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: _refresh,
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _selectPage(index);
        },
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Check In / Check Out',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Employé",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.present_to_all),
            label: "Présences",
          ),
        ],
      ),
      body: _activePage,
    );
  }
}
