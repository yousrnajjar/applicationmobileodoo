/// Purpose: This file constains à widget that displays the list of holidays
///          for the current user if he is an employee, or for all employees
///          if he is a manager. Database is accessed through Odoo API.
///          Also, this widget constains at top a button to filter the list by status.
///          The list is displayed in a [ListView] with a [Card] for each holiday.
///          Each [Card] contains a [ListTile] with the following fields:
///          - [Holiday.dateFrom] and [Holiday.dateTo] (dates of the holiday)
///          - [Holiday.numberOfDaysDisplay] (number of days of the holiday)
///          - [Holiday.holidayStatusId] (type of holiday)
///          - [Holiday.state] (status of the holiday)
///          All this is shifted to the right by a [Padding] with a width of 16.0.
///          If the user is a manager, the [ListTile] also contains the name of the employee.
///          Also, if the user is a manager, the [Card] contains a [Button] to approve or refuse the holiday.
///          All this is shifted to left of preceding
///          Odoo admin have all rights to approve or refuse holidays.

/// For now we just create a widget with dummy data withowt using Odoo API

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/core/widgets/hr_holidays/allocation_form.dart';
import 'package:smartpay/core/widgets/hr_holidays/holidays_calendar_view.dart';
import 'package:smartpay/core/widgets/hr_holidays/leave_form.dart';
import 'package:smartpay/exceptions/api_exceptions.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/allocation.dart';
import 'package:smartpay/ir/models/holidays.dart';
import 'package:smartpay/ir/models/user.dart';

/// dummy data with fields [date_from], [date_to], [holiday_status_id], [state], [employee_id], [number_of_days_display], [can_approve], [can_reset],
/// [date_from] and [date_to] are [DateTime] objects
/// It for 5 holidays with 3 different [holiday_status_id] and 2 different [state]
/// and 2 different employee : ['John Doe', 'Jane Doe']
List<String> names = [
  'John Doe',
  'Jane Doe',
  'Jack Doe',
  'Jill Doe',
  'James Doe',
  'Judy Doe',
  'Jules Doe',
  'Julia Doe',
  'Jasper Doe',
  'Jasmine Doe'
];

String randomHolidayStatusId() {
  List<String> holidayStatusIds = [
    "Paid Time Off",
    "Unpaid Time Off",
    "Sick Leave",
  ];
  return holidayStatusIds[DateTime.now().microsecondsSinceEpoch % 3];
}

String randomState() {
  List<String> states = [
    "validate",
    "refuse",
    "draft",
  ];
  return states[DateTime.now().microsecondsSinceEpoch % 2];
}

DateTime randomDate() {
  DateTime now = DateTime.now();
  DateTime date = DateTime(now.year, now.month, now.day);
  int randomDays = DateTime.now().microsecondsSinceEpoch % 100;
  return date.add(Duration(days: randomDays));
}

bool randomBool() {
  return DateTime.now().microsecondsSinceEpoch % 2 == 0;
}

String randomName() {
  return names[DateTime.now().microsecondsSinceEpoch % 10];
}

int randomDays() {
  return DateTime.now().microsecondsSinceEpoch % 10;
}

List<Map<String, dynamic>> generateRandomHolidays(int n) {
  List<Map<String, dynamic>> holidays = List.generate(
      n,
      (index) => {
            "date_from": randomDate(),
            "date_to": randomDate(),
            "holiday_status_id": randomHolidayStatusId(),
            "state": randomState(),
            "employee_id": randomName(),
            "number_of_days_display": "3",
            "can_approve": true,
            "can_reset": true,
          });
  return holidays;
}

// List<Map<String, dynamic>> listHolidays

List<Map<String, dynamic>> holidays = List.generate(
    20,
    (index) => {
          "date_from": randomDate(),
          "date_to": randomDate(),
          "holiday_status_id": randomHolidayStatusId(),
          "state": randomState(),
          "employee_id": randomName(),
          "number_of_days_display": "3",
          "can_approve": true,
          "can_reset": true,
        });

/// function to generate a user data with fields [name], [is_manager], [is_admin]
Map<String, dynamic> generateRandomUser() {
  List<bool> isManagers = [true, false];
  List<bool> isAdmins = [true, false];
  // generate random index for each list
  int nameIndex =
      (names.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)
          .floor();
  int isManagerIndex = (isManagers.length *
          (DateTime.now().millisecondsSinceEpoch % 1000) /
          1000)
      .floor();
  int isAdminIndex =
      (isAdmins.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)
          .floor();
  // return a map with the fields
  return {
    "name": names[nameIndex],
    "is_manager": true, //isManagers[isManagerIndex],
    "is_admin": isAdmins[isAdminIndex],
  };
}

/// This widget displays the holiday item in a [Card] like described above
/// It takes a [Map<String, dynamic>] as parameter with the fields described above
/// also takes a [user] parameter with the fields described above
/// It returns a [Card] with a [ListTile] with the fields described above
/// If the user is a manager, it also contains a [Button] to approve or refuse the holiday
/// If the user is an employee, it also contains a [Button] to cancel the holiday
/// The [Button] are displayed only if the user has the right to approve, refuse or cancel the holiday
/// Admin have all rights to approve, refuse or cancel holidays

class HolidayItem extends StatelessWidget {
  final Map<String, dynamic> holiday;
  final bool isManager;
  final Function(int, String) doAction;

  const HolidayItem(
      {super.key,
      required this.holiday,
      required this.isManager,
      required this.doAction});

  @override
  Widget build(BuildContext context) {
    // check if the user can approve the holiday
    bool canApprove =
        ['confirm', 'validate1'].contains(holiday['state']) && isManager;
    // check if the user can refuse the holiday
    bool canRefuse = ['draft', 'confirm', 'validate', 'validate1']
            .contains(holiday['state']) &&
        isManager;
    // Theme of context
    final ThemeData theme = Theme.of(context);

    // Color by holiday state
    Map<String, Color> stateColors = {
      'validate': kLightGreen,
      'refuse': kLightOrange,
      'confirm': kLightPink,
    };

    Map<String, Color> stateTextColors = {
      'validate': kGreen,
      'refuse': Colors.redAccent,
      'confirm': kGrey,
    };

    // small text style

    var dateFormat = DateFormat('yyyy-MM-dd');
    var emptyString = '--------';
    var bodyLarge = theme.textTheme.bodyLarge!;
    var valueStyle = bodyLarge.copyWith(
      color: kGrey,
      fontWeight: FontWeight.normal,
    );
    var labelTextStyle = valueStyle.copyWith(
      fontWeight: FontWeight.w900,
    );

    String dateFromDisplay;
    String dateToDisplay;

    var dateFrom = dateFormat.parse(holiday['date_from']);
    dateFromDisplay = dateFormat.format(dateFrom);
    var dateTo = dateFormat.parse(holiday['date_to']);
    dateToDisplay = dateFormat.format(dateTo);

    var state = holiday['state'];
    var stateDisplay = holiday['state_display'];
    var numberOfDaysDisplay = holiday['number_of_days_display'] ?? emptyString;
    var holidayStatusIdDisplay = holiday['holiday_status_id'][1];
    var employeeIdDisplay = holiday['employee_id'][1];

    // return a [Card] with a [ListTile] with the fields described above with a background color depending of the state
    // At left of the [ListTile], we display the [date_from] (Du) and [date_to] (Au) in a same [Row]
    // and below, we display the number of days with its label (Nombre de jours: ) in a [Row]
    // below, we display the [holiday_status_id] with its label (Type de congé: ) in a [Row]
    // below, we display the [state] (Etat: ) with a color depending of the state and its label (Etat: ) in a [Row]
    // below, we display the [employee_id] (Employé: ).
    // All labels are displayed with a [Text] widget with a bold font and display in same [Row] with the value (normal font)
    // At right of the [ListTile], we display the [Button] to approve, refuse or cancel the holiday
    // if the [user] has the right to do it. The [Button] are displayed with colors depending of the action
    // for now, the [Button] are not functional and only display a [SnackBar] with the action name

    return Card(
      margin: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(),
      color: stateColors[state],
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Du: ', style: labelTextStyle),
                    Text(dateFromDisplay, style: valueStyle),
                    Text(' Au: ', style: labelTextStyle),
                    Text(dateToDisplay, style: valueStyle),
                  ],
                ),
                Row(
                  children: [
                    Text('Nombre de jour: ', style: labelTextStyle),
                    Text("$numberOfDaysDisplay", style: valueStyle),
                  ],
                ),
                Row(
                  children: [
                    Text('Type de congé: ', style: labelTextStyle),
                    Text(holidayStatusIdDisplay, style: valueStyle),
                  ],
                ),
                Row(
                  children: [
                    Text('Etat: ',
                        style: labelTextStyle.copyWith(
                            color: stateTextColors[state])),
                    Text(stateDisplay,
                        style: labelTextStyle.copyWith(
                            color: stateTextColors[state])),
                  ],
                ),
                Row(
                  children: [
                    Text('Employé: ', style: labelTextStyle),
                    Text(employeeIdDisplay, style: valueStyle),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canApprove)
                  InkWell(
                    onTap: () {
                      doAction(holiday['id'], 'approve');
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                              "assets/icons/holiday/icone_approuvee.png"),
                          const SizedBox(width: 5),
                          Text('Approuver',
                              style: labelTextStyle.copyWith(color: kGreen)),
                        ],
                      ),
                    ),
                  ),
                if (canRefuse)
                  InkWell(
                    onTap: () {
                      doAction(holiday['id'], 'refuse');
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset("assets/icons/holiday/icone_refuse.png"),
                          const SizedBox(width: 5),
                          Text('Refuser',
                              style: labelTextStyle.copyWith(
                                  color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// This class is used to display a list of holidays in a [ListView] widget
/// It takes a [holidays] parameter with a list of holidays
/// It takes a [employee] parameter with the user information
///
/// On top of the [ListView], 3 [Button] are displayed to filter the list of holidays and can scroll horizontally if there are too many
/// There are 3 [Tout], [Congés validés] and [Congés refusés]
/// These [Button] are displayed only if the user is a manager or an admin

class HolidayList extends StatefulWidget {
  final User user;

  const HolidayList({super.key, required this.user});

  @override
  State<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {
  // The current filter
  String _filter = 'all';
  List<Map<String, dynamic>> _holidays = [];
  bool isLoaded = false;

  /// Request the list of holidays from the API
  Future<void> _getHolidays() async {
    // Get the list of holidays
    //try {
    var holidayFields = <String>[
      'id',
      "date_from",
      "date_to",
      "number_of_days",
      "holiday_status_id",
      "state",
      "employee_id",
      "number_of_days_display",
      "can_approve",
      "can_reset"
    ];
    holidays =
        await widget.user.getHolidayDetails(holidayFields: holidayFields);
    /*} catch (e) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la récupération des congés'),
        ),
      );
      return;
    }*/
    // If the request succeed, update the state with the list of holidays
    List<OdooField> stateDetails =
        await OdooModel("hr.leave").getAllFields(fieldNames: ['state']);
    var selectionOptions = stateDetails[0].selectionOptions;
    for (var hol in holidays) {
      var stateRecord =
          selectionOptions.where((e) => e['value'] == hol['state']).toList();
      hol['state_display'] = stateRecord[0]['display_name'];
    }
    setState(() {
      _holidays = holidays;
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) _getHolidays();

    // Theme of context
    final ThemeData theme = Theme.of(context);

    // User information
    bool isManager = widget.user.isManager || widget.user.isAdmin;
    // List of holidays filtered by the current filter
    List<Map<String, dynamic>> filteredHolidays = _holidays.where((holiday) {
      if (_filter == 'all') {
        return true;
      } else if (_filter == 'validate') {
        return holiday['state'] == 'validate';
      } else if (_filter == 'refuse') {
        return holiday['state'] == 'refuse';
      } else if (_filter == 'confirm') {
        return holiday['state'] == 'confirm';
      } else {
        return false;
      }
    }).toList();

    //
    var selectedColor = kGreen;
    var btnTextColor = theme.textTheme.bodyLarge!
        .copyWith(color: kGreen, fontWeight: FontWeight.bold);
    var btnNotSelectedColor = const Color.fromARGB(255, 217, 216, 216);

    if (!isLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filter = 'all';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _filter == 'all' ? selectedColor : btnNotSelectedColor,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text('Tout',
                      style: _filter == 'all'
                          ? btnTextColor.copyWith(color: Colors.white)
                          : btnTextColor),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filter = 'confirm';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'confirm'
                        ? selectedColor
                        : btnNotSelectedColor,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text('À Approuver',
                      style: _filter == 'confirm'
                          ? btnTextColor.copyWith(color: Colors.white)
                          : btnTextColor),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filter = 'validate';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'validate'
                        ? selectedColor
                        : btnNotSelectedColor,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text('Validés',
                      style: _filter == 'validate'
                          ? btnTextColor.copyWith(color: Colors.white)
                          : btnTextColor),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filter = 'refuse';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'refuse'
                        ? selectedColor
                        : btnNotSelectedColor,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text('Refusés',
                      style: _filter == 'refuse'
                          ? btnTextColor.copyWith(color: Colors.white)
                          : btnTextColor),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHolidays.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: HolidayItem(
                    key: ValueKey(filteredHolidays[index]['id']),
                    holiday: filteredHolidays[index],
                    isManager: isManager,
                    doAction: (int id, String action) async {
                      if (!isManager) return;
                      bool res = false;
                      try {
                        if (action == 'approve') {
                          res = await Holiday.validate(id);
                        } else if (action == 'refuse') {
                          res = await Holiday.refuse(id);
                        }
                      } on OdooErrorException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                          ),
                        );
                        return;
                      }
                      if (res) {
                        _getHolidays();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          HolidayCalendar(
              holidays:
                  filteredHolidays.map((e) => Holiday.fromJSON(e)).toList())
        ],
      );
    }
  }
}

/// Scaffold of the holiday page [HolidayScreen]
/// By default, the page display the list of holidays [HolidayList]
/// The page also contains a [BottomNavigationBar] to navigate between hystory , hilyday form, allocation form
/// Note that we can not navigate to the holiday list page from the bottom navigation bar
///
/// The page takes a [employee] parameter with the user information
// for history page, we just print Text : History page
// for holiday form page, we just print Text : Holiday form page
// for allocation form page, we just print Text : Allocation form page
class HolidayScreen extends StatefulWidget {
  final User user;
  // onTitleChanged is a callback function to change the title of the page
  final Function(String) onTitleChanged;

  const HolidayScreen(
      {super.key, required this.user, required this.onTitleChanged});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  // The current page
  int _selectedIndex = 0;

  // List of pages
  final List<Widget> _pages = [];
  final List<String> _pageTitle = [
    'Congés',
    'Demande de congé',
    'Demande d\'allocation'
  ];

  @override
  void initState() {
    super.initState();
    // Add the holiday list page
    _pages.add(HolidayList(user: widget.user));
    // Add the holiday form page
    _pages.add(const Center(child: CircularProgressIndicator()));
    // Add the allocation form page
    _pages.add(const Center(child: CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    var appBarForeground = Theme.of(context).appBarTheme.foregroundColor;
    return Scaffold(
      body: Container(
          margin: const EdgeInsets.only(top: 30, left: 15, right: 15),
          child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          widget.onTitleChanged(_pageTitle[index]);
          if ([1, 2].contains(index)) {
            _buildForm(index);
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon:
                Image.asset("assets/icons/holiday/icone_historique_conge.png"),
            label: 'Liste des congés',
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/holiday/icone_demande_conge.png"),
            label: 'Demande de congé',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
                "assets/icons/holiday/icone_demande_allocation.png"),
            label: 'Demande d\'allocation',
          ),
        ],
      ),
    );
  }

  _buildForm(int index) async {
    Widget? content;
    if (index == 1) {
      content = await buildHolidayForm();
    } else if (index == 2) {
      /*content = await OdooModel("hr.leave.allocation").buildFormFields(
        fieldNames: Allocation.defaultFields,
        onChangeSpec: Allocation.onchangeSpec,
        formTitle: "Demande d'Allocation",
        displayFieldNames: Allocation.displayFieldNames,
      );*/
      content = await buildAllocationForm();
    }
    if (content != null) {
      setState(() {
        _pages[index] = content!;
      });
    }
  }

  Future<Widget> buildHolidayForm() async {
    /*return await OdooModel("hr.leave").buildFormFields(
      fieldNames: Holiday.defaultFields,
      onChangeSpec: Holiday.onchangeSpec,
      formTitle: "Demande de congé",
      displayFieldNames: Holiday.displayFieldNames,
    );*/
    var fieldNames = Holiday.defaultFields;
    var displayFieldNames = Holiday.displayFieldNames;
    var onChangeSpec = Holiday.onchangeSpec;
    var formTitle = "Demande de congé";
    var model = OdooModel("hr.leave");

    Map<OdooField, dynamic> initial =
        await model.defaultGet(fieldNames, onChangeSpec);
    Map<OdooField,
            Future<Map<OdooField, dynamic>> Function(Map<OdooField, dynamic>)>
        onFieldChanges = {};
    for (OdooField field in initial.keys) {
      onFieldChanges[field] = (Map<OdooField, dynamic> currentValues) async {
        return await model.onchange([field], currentValues, onChangeSpec);
      };
    }

    return HolidayForm(
      key: ObjectKey(this),
      fieldNames: fieldNames,
      initial: initial,
      onFieldChanges: onFieldChanges,
      displayFieldsName: displayFieldNames,
      title: formTitle,
      onSaved: (Map<OdooField, dynamic> values) async {
        return await model.create(values);
      },
    );
  }

  Future<Widget> buildAllocationForm() async {
    /*return await OdooModel("hr.leave.allocation").buildFormFields(
      fieldNames: Allocation.defaultFields,
      onChangeSpec: Allocation.onchangeSpec,
      formTitle: "Demande de congé",
      displayFieldNames: Allocation.displayFieldNames,
    );*/
    var fieldNames = Allocation.defaultFields;
    var displayFieldNames = Allocation.displayFieldNames;
    var onChangeSpec = Allocation.onchangeSpec;
    var formTitle = "Demande de congé";
    var model = OdooModel("hr.leave.allocation");

    Map<OdooField, dynamic> initial =
        await model.defaultGet(fieldNames, onChangeSpec);
    Map<OdooField,
            Future<Map<OdooField, dynamic>> Function(Map<OdooField, dynamic>)>
        onFieldChanges = {};
    for (OdooField field in initial.keys) {
      onFieldChanges[field] = (Map<OdooField, dynamic> currentValues) async {
        return await model.onchange([field], currentValues, onChangeSpec);
      };
    }
    return AllocationForm(
      key: ObjectKey(this),
      fieldNames: fieldNames,
      initial: initial,
      onFieldChanges: onFieldChanges,
      displayFieldsName: displayFieldNames,
      title: formTitle,
      onSaved: (Map<OdooField, dynamic> values) async {
        return await model.create(values);
      },
    );
  }
}
