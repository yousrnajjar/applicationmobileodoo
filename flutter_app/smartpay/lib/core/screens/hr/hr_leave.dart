import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/hr_attendance/attendance_list.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/employee.dart';
import 'package:smartpay/core/widgets/hr_attendance2/check_in_check_out.dart';

class InOutScreen extends StatefulWidget {
  final Function(String) onTitleChanged;

  const InOutScreen({
    super.key,
    required this.onTitleChanged,
  });
  @override
  State<InOutScreen> createState() => _InOutScreenState();
}

class _InOutScreenState extends State<InOutScreen> {
  late EmployeeAllInfo _employee;
  Widget _activePage = const Text("Hello");
  int _selectedPageIndex = 0;
  Future<EmployeeAllInfo> _getEmployee() async {
    var employeeData = await OdooModel("hr.employee").searchRead(
      domain: [
        ['user_id', '=', OdooModel.session.uid]
      ],
      fieldNames: EmployeeAllInfo().allFields,
      limit: 1,
    );
    return EmployeeAllInfo.fromJson(employeeData[0]);
  }

  @override
  void initState() {
    super.initState();
    _getEmployee().then((value) {
      setState(() {
        _employee = value;
        _activePage = CheckInCheckOut(
          employee: _employee,
        );
      });
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    if (index == 0) {
      setState(() {
        _activePage = CheckInCheckOut(
          employee: _employee,
        );
      });
    } else if (index == 1) {
      setState(() {
        _activePage = AttendanceList(
          employeeId: _employee.id!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _selectPage(index);
        },
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/fingerprint.png"),
            ),
            label: 'Pointage',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/history.png"),
            ),
            label: "Historique",
          ),
        ],
      ),
      body: _activePage,
    );
  }
}
