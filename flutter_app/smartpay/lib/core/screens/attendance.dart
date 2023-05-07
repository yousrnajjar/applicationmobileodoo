import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/attendance.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/core/widgets/attendance/check_in_out.dart';
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
  void _getAttendanceInfo() async {
    UserInfo userInfo = ref.watch(userInfoProvider);
    Session session = ref.watch(sessionProvider);
    AttendanceAPI api = AttendanceAPI(session);
    EmployeeAttendanceInfo attendanceInfo = await api.getInfo(userInfo.uid);
    ref.read(userAttendanceProvider.notifier).setAttendance(attendanceInfo);
  }

  int _selectedPageIndex = 0;
  late Widget _activePage;
  @override
  void initState() {
    super.initState();
    _activePage = const CheckInOut();
  }

  void _selectPage(int index) {
    if (index == 0) {
      setState(() {
        _activePage = const CheckInOut();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Présence"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: _getAttendanceInfo,
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
