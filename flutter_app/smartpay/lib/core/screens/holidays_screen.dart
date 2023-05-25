import 'package:flutter/material.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/holidays_models.dart';
import 'package:smartpay/ir/models/allocation_models.dart';
import 'package:smartpay/core/widgets/holidays/holidays_calendar_view.dart'
    as holiday_cal;
import 'package:smartpay/core/widgets/holidays/my_holidays_widget.dart';
import 'package:smartpay/ir/models/user_info.dart';

class HolidaysScreen extends StatefulWidget {
  final User user;
  const HolidaysScreen(this.user, {super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

enum HolidaysPage {
  none,
  myHolidays,
  holidayCalandar,
  createHolidays,
  createAllocation
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  HolidaysPage _selectedPage = HolidaysPage.none;
  late Widget _activePage;
  int _selectedPageIndex = 0;
  List<Holiday> _holidays = [];

  @override
  void initState() {
    super.initState();
    _activePage = const SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Future<List<Holiday>> _getHolidays() async {
    var employeeData = await widget.user.getEmployeeData();
    if (employeeData.isEmpty) return [];
    var myHolidaysData = await OdooModel("hr.leave").searchRead(domain: [
      ['employee_id', '=', employeeData[0]['id']]
    ], fieldNames: Holiday.allFields);
    return myHolidaysData.map((e) => Holiday.fromJSON(e)).toList();
  }

  Future<void> _refresh() async {
    if (_selectedPage == HolidaysPage.myHolidays) {
      /*var holidays = await _getHolidays();
      setState(() {
        _holidays = holidays;
      });*/
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
      _holidays = await _getHolidays();
      setState(() {
        _activePage = HolidaysWidget(widget.user, list: _holidays);
        _selectedPageIndex = 0;
      });
    } else if (index == 1) {
      _selectedPage = HolidaysPage.createHolidays;
      var employeeData = await widget.user.getEmployeeData();
      if (employeeData.isEmpty) return;
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
    } else if (index == 2) {
      _selectedPage = HolidaysPage.createAllocation;
      var employeeData = await widget.user.getEmployeeData();
      if (employeeData.isEmpty) return;
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
    } else if (index == 3) {
      _selectedPage = HolidaysPage.holidayCalandar;
      var employeeData = await widget.user.getEmployeeData();
      if (employeeData.isEmpty) return;
      var holidaysData = await OdooModel("hr.leave").searchRead(
        domain: [
          ['employee_id', '=', employeeData[0]['id']]
        ],
        fieldNames: Holiday.allFields
      );
      var holidays = holidaysData.map((e) => Holiday.fromJSON(e)).toList();
      setState(() {
        _activePage = holiday_cal.HolidayCalendar(
          holidays: holidays,
        );
        _selectedPageIndex = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPage == HolidaysPage.none) {
      _selectedPage = HolidaysPage.myHolidays;
      _selectPage(0);
    }
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
