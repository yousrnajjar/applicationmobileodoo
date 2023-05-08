import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/attendance.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/core/widgets/attendance/attendance_list.dart';
import 'package:smartpay/core/widgets/attendance/check_in_out.dart';
import 'package:smartpay/providers/attendance_list_providers.dart';
import 'package:smartpay/providers/models/user_info.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:smartpay/providers/user_attendance_info.dart';
import 'package:smartpay/providers/user_info_providers.dart';

class InOutScreen extends ConsumerStatefulWidget {
  const InOutScreen({super.key});

  @override
  ConsumerState<InOutScreen> createState() => _InOutScreenState();
}

class _InOutScreenState extends ConsumerState<InOutScreen> {
  late String _selectedPage;
  late Widget _activePage = const CheckInOut();
  int _selectedPageIndex = 0;

  
  Future<void> _refresh() async {
    if (_selectedPage == "in_out") {
      UserInfo userInfo = ref.watch(userInfoProvider);
      Session session = ref.watch(sessionProvider);
      AttendanceAPI api = AttendanceAPI(session);
      EmployeeAttendanceInfo attendanceInfo = await api.getInfo(userInfo.uid);
      print(attendanceInfo.attendanceState);
      ref.read(userAttendanceProvider.notifier).setAttendance(attendanceInfo);
    } else if (_selectedPage == 'attendance_list') {
      Session session = ref.watch(sessionProvider);
      AttendanceAPI api = AttendanceAPI(session);
      EmployeeAttendanceInfo info = ref.watch(userAttendanceProvider);
      List<Attendance> attendances = await api.getAttentances(info.id);
      ref.read(attendancesProvider.notifier).setAttendances(attendances);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectPage(0);
  }

  Future<void> _selectPage(int index) async {
    if (index == 0) {
      _selectedPage = "in_out";
      await _refresh();
      setState(() {
        _activePage = const CheckInOut();
        _selectedPageIndex = 0;
      });
    }
    if (index == 2) {
      _selectedPage = "attendance_list";
      await _refresh();
      setState(() {
        _activePage = const AttendanceList();
        _selectedPageIndex = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
