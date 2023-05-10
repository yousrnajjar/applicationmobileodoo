import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/attendance.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/api/models.dart';
import 'package:smartpay/providers/attendance_list_providers.dart';
import 'package:smartpay/providers/models/user_info.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:smartpay/providers/user_attendance_info.dart';
import 'package:smartpay/providers/user_info_providers.dart';

class HolydaysScreen extends ConsumerStatefulWidget {
  const HolydaysScreen({super.key});

  @override
  ConsumerState<HolydaysScreen> createState() => _HolydaysScreenState();
}

enum HolydaysPage { myHolydays, createHolydays }

class _HolydaysScreenState extends ConsumerState<HolydaysScreen> {
  HolydaysPage _selectedPage = HolydaysPage.myHolydays;
  Widget _activePage = const Scaffold(
    body: Text("My Holydays"),
  );
  int _selectedPageIndex = 0;

  Future<void> _refresh() async {
    if (_selectedPage == HolydaysPage.myHolydays) {
      UserInfo userInfo = ref.watch(userInfoProvider);
      Session session = ref.watch(sessionProvider);
      AttendanceAPI api = AttendanceAPI(session);
      Employee employee = await api.getEmployee(userInfo.uid);
      ref.read(currentEmployeeProvider.notifier).setAttendance(employee);
    } else if (_selectedPage == HolydaysPage.createHolydays) {
      Session session = ref.watch(sessionProvider);
      AttendanceAPI api = AttendanceAPI(session);
      Employee info = ref.watch(currentEmployeeProvider);
      List<Attendance> attendances = await api.getAttentances(info.id);
      ref.read(attendancesProvider.notifier).setAttendances(attendances);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectPage(int index) async {
    if (index == 0) {
      _selectedPage = HolydaysPage.myHolydays;
      await _refresh();
      setState(() {
        _activePage = const Scaffold(
          body: Text("My Holydays"),
        );
        _selectedPageIndex = 0;
      });
    } else if (index == 1) {
      _selectedPage = HolydaysPage.createHolydays;
      await _refresh();
      setState(() {
        _activePage = const Scaffold(
          body: Text("Create holydays"),
        );
        _selectedPageIndex = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Congé"), actions: <Widget>[
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
            label: 'Mes Congés',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Demande de Congé",
          ),
        ],
      ),
      body: _activePage,
    );
  }
}
