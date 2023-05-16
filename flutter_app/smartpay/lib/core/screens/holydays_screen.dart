import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/api/holydays/holydays_api.dart';
import 'package:smartpay/api/holydays/holydays_models.dart';
import 'package:smartpay/core/widgets/holydays/holyday_form_widget.dart';
import 'package:smartpay/core/widgets/holydays/my_holydays_widget.dart';
import 'package:smartpay/providers/employee_list_providers.dart';
import 'package:smartpay/providers/my_holydays_list_provider.dart';
import 'package:smartpay/providers/models/user_info.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:smartpay/providers/user_info_providers.dart';

class HolydaysScreen extends ConsumerStatefulWidget {
  const HolydaysScreen({super.key});

  @override
  ConsumerState<HolydaysScreen> createState() => _HolydaysScreenState();
}

enum HolydaysPage { myHolydays, createHolydays }

class _HolydaysScreenState extends ConsumerState<HolydaysScreen> {
  HolydaysPage _selectedPage = HolydaysPage.myHolydays;
  Widget _activePage = const MyHolydaysWidget();
  int _selectedPageIndex = 0;
  late Session _session;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    HolydaysAPI api = HolydaysAPI(_session);
    if (_selectedPage == HolydaysPage.myHolydays) {
      UserInfo userInfo = ref.watch(userInfoProvider);
      List<Holyday> myHolydays = await api.getMyHolydays(userInfo.uid);
      ref.read(myHolydaysProvider.notifier).setMyHolydays(myHolydays);
    } else if (_selectedPage == HolydaysPage.createHolydays) {
      /*Session session = ref.watch(sessionProvider);
      HolydaysAPI api = HolydaysAPI(session);
      Employee info = ref.watch(currentEmployeeProvider);
      List<Attendance> attendances = await api.getAttentances(info.id);
      ref.read(attendancesProvider.notifier).setAttendances(attendances);*/
    }
  }

  Future<void> _selectPage(int index) async {
    if (index == 0) {
      _selectedPage = HolydaysPage.myHolydays;
      await _refresh();
      setState(() {
        _activePage = const MyHolydaysWidget();
        _selectedPageIndex = 0;
      });
    } else if (index == 1) {
      _selectedPage = HolydaysPage.createHolydays;
      Session session = ref.watch(sessionProvider);
      HolydaysAPI api = HolydaysAPI(session);
      var types = await api.getHolidayTypes();
      await _refresh();
      var employeeId = ref.watch(myHolydaysProvider.notifier).getEmployeeId();
      if (employeeId != null) {
        setState(() {
          _activePage = Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text(
                      "Demande de congé",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                  HolydayForm(
                    session: _session,
                    employeeId: employeeId!,
                    holydaysStatus: types,
                  ),
                ],
              ),
            ),
          );
          _selectedPageIndex = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _session = ref.watch(sessionProvider);
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
