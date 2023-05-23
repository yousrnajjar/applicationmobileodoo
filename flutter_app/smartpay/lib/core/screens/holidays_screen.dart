import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/session.dart';
import 'package:smartpay/api/holidays_api.dart';
import 'package:smartpay/models/holidays_models.dart';
import 'package:smartpay/core/widgets/holidays/allocation_form_widget.dart';
import 'package:smartpay/core/widgets/holidays/holidays_calendar_view.dart'
    as holiday_cal;
import 'package:smartpay/core/widgets/holidays/my_holidays_widget.dart';
import 'package:smartpay/core/widgets/snippets/forms.dart';
import 'package:smartpay/providers/my_holidays_list_provider.dart';
import 'package:smartpay/providers/models/user_info.dart';
import 'package:smartpay/providers/session_providers.dart';
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
  List<HolidayType> _holidaysTypes = [];
  bool _holidaysTypesIsLoad = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getHolidaysType(Session session) async {
    HolidaysAPI api = HolidaysAPI(session);
    var types = await api.getHolidayTypes();
    if (context.mounted) {
      setState(() {
        _holidaysTypes = types;
        _holidaysTypesIsLoad = true;
      });
    }
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
      var employeeId = ref.watch(myHolidaysProvider.notifier).getEmployeeId();
      if (employeeId != null) {
        var page = await Holiday.buildFormFields(_session);
        setState(() {
          /*_activePage = FormSnippet(
            mainContaint: HolidayForm(
              session: _session,
              employeeId: employeeId,
              holidaysStatus: _holidaysTypes,
            ),
            title: "Demande de congé",
          );*/
          _activePage = page;
          _selectedPageIndex = 1;
        });
      }
    } else if (index == 2) {
      _selectedPage = HolidaysPage.createAllocation;
      setState(() {
        _activePage = FormSnippet(
          mainContaint: FormulaireDemandeAllocation(
            holidaysStatus: _holidaysTypes,
          ),
          title: "Demande d'allocation",
        );
        _selectedPageIndex = 2;
      });
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
    if (!_holidaysTypesIsLoad) _getHolidaysType(_session);
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
