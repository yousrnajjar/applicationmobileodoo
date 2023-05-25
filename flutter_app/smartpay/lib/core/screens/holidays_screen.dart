import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/session.dart';
import 'package:smartpay/api/holidays_api.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/holidays_models.dart';
import 'package:smartpay/ir/models/allocation_models.dart';
import 'package:smartpay/core/widgets/holidays/holidays_calendar_view.dart'
    as holiday_cal;
import 'package:smartpay/core/widgets/holidays/my_holidays_widget.dart';
import 'package:smartpay/providers/my_holidays_list_provider.dart';
import 'package:smartpay/ir/models/user_info.dart';
import 'package:smartpay/core/providers/session_providers.dart';
import 'package:smartpay/providers/user_info_providers.dart';

class HolidaysScreen extends ConsumerStatefulWidget {
  const HolidaysScreen({super.key});

  @override
  ConsumerState<HolidaysScreen> createState() => _HolidaysScreenState();
}

enum HolidaysPage {
  myHolidays,
  holidayCalandar,
  createHolidays,
  createAllocation
}

class _HolidaysScreenState extends ConsumerState<HolidaysScreen> {
  HolidaysPage _selectedPage = HolidaysPage.myHolidays;
  Widget _activePage = const MyHolidaysWidget();
  int _selectedPageIndex = 0;
  late Session _session;

  @override
  void initState() {
    super.initState();
  }


  Future<void> _refresh() async {
    HolidaysAPI api = HolidaysAPI(_session);
    if (_selectedPage == HolidaysPage.myHolidays) {
      UserInfo userInfo = ref.watch(userInfoProvider);
      List<Holiday> myHolidays = await api.getMyHolidays(userInfo.uid);
      ref.read(myHolidaysProvider.notifier).setMyHolidays(myHolidays);
    } else if (_selectedPage == HolidaysPage.createHolidays) {
      /*Session session = ref.watch(sessionProvider);
      HolidaysAPI api = HolidaysAPI(session);
      Employee info = ref.watch(currentEmployeeProvider);
      List<Attendance> attendances = await api.getAttentances(info.id);
      ref.read(attendancesProvider.notifier).setAttendances(attendances);*/
    }
  }

  Future<void> _selectPage(int index) async {
    var employeeId = ref.watch(myHolidaysProvider.notifier).getEmployeeId();
    if (index == 0) {
      _selectedPage = HolidaysPage.myHolidays;
      await _refresh();
      setState(() {
        _activePage = const MyHolidaysWidget();
        _selectedPageIndex = 0;
      });
    } else if (index == 1) {
      _selectedPage = HolidaysPage.createHolidays;
      await _refresh();
      if (employeeId != null) {
        var holidayModel = OdooModel("hr.leave");
        var page = await holidayModel.buildFormFields(
          fieldNames: Holiday.defaultFields,
          onChangeSpec: Holiday.onchangeSpec,
          formTitle: "Demande de congé",
          displayFieldNames: Holiday.displayFieldNames,
        );
        setState(() {
          _activePage = page;
          _selectedPageIndex = 1;
        });
      }
    } else if (index == 2) {
      _selectedPage = HolidaysPage.createAllocation;
      await _refresh();
      if (employeeId != null) {
        var allocationModel = OdooModel("hr.leave.allocation");
        var page = await allocationModel.buildFormFields(
          fieldNames: Allocation.defaultFields,
          formTitle: "Demande d'allocation",
          onChangeSpec: Allocation.onchangeSpec,
          displayFieldNames: Allocation.displayFieldNames,
        );

        setState(() {
          _activePage = page;
          _selectedPageIndex = 2;
        });
      }
    } else if (index == 3) {
      _selectedPage = HolidaysPage.holidayCalandar;
      setState(() {
        var myHolidays = ref.watch(myHolidaysProvider);
        _activePage = holiday_cal.HolidayCalendar(
          holidays: myHolidays,
        );
        _selectedPageIndex = 3;
      });
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
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Mes Congés',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: "Demande",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Allocation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Congé",
          )
        ],
      ),
      body: _activePage,
    );
  }
}
