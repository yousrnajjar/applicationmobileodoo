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
    "confirm",
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

List<Map<String, dynamic>> holidays = List.generate(
    20,
    (index) => {
          "date_from": randomDate(),
          "date_to": randomDate(),
          "holiday_status_id": randomHolidayStatusId(),
          "state": randomState(),
          "employee_id": randomName(),
          "number_of_days_display": "3",
          "can_approve": randomBool(),
          "can_reset": randomBool(),
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
    "is_manager": isManagers[isManagerIndex],
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
  final Map<String, dynamic> user;

  const HolidayItem({super.key, required this.holiday, required this.user});

  @override
  Widget build(BuildContext context) {
    // check if the user is a manager
    bool isManager = user['is_manager'];
    // check if the user is an admin
    bool isAdmin = user['is_admin'];
    // check if the user can approve the holiday
    bool canApprove = holiday['can_approve'] && (isManager || isAdmin);
    // check if the user can refuse the holiday
    bool canRefuse = holiday['can_reset'] && (isManager || isAdmin);
    // check if the user can cancel the holiday
    bool canCancel = holiday['can_reset'] && !isManager && !isAdmin;

    // Theme of context
    final ThemeData theme = Theme.of(context);

    // Color by holiday state
    Map<String, Color> stateColors = {
      'validate': Colors.green,
      'refuse': Colors.red,
      'cancel': Colors.red,
      'draft': Colors.orange,
    };

    // small text style
    TextStyle smallTextStyle = theme.textTheme.bodyText2!.copyWith(
      fontSize: 8,
    );
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
      color: stateColors[holiday['state']],
      child: ListTile(
        title: Row(
          children: [
            Text('Du: ',
                style: theme.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(DateFormat('dd/MM/yyyy').format(holiday['date_from']),
                style: theme.textTheme.bodyLarge!),
            Text(' Au: ',
                style: theme.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(DateFormat('dd/MM/yyyy').format(holiday['date_to']),
                style: theme.textTheme.bodyLarge!),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Nombre de jours: ',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(holiday['number_of_days_display'],
                    style: theme.textTheme.bodyLarge!),
              ],
            ),
            Row(
              children: [
                Text('Type de congé: ',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(holiday['holiday_status_id'],
                    style: theme.textTheme.bodyLarge!),
              ],
            ),
            Row(
              children: [
                Text('Etat: ',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(holiday['state'],
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: Colors.white)),
              ],
            ),
            Row(
              children: [
                Text('Employé: ',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold)),
                Text(holiday['employee_id'], style: theme.textTheme.bodyLarge!),
              ],
            ),
          ],
        ),
        // Todo: Use TextButton instead of ElevatedButton
        trailing: Column(
          children: [
            if (canApprove)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Approuver'),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: smallTextStyle,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Approuver'),
              ),
            if (canRefuse)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Refuser'),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  textStyle: smallTextStyle,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Refuser'),
              ),
            if (canCancel)
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Annuler'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  textStyle: smallTextStyle,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Annuler'),
              ),
          ],
        ),
      ),
    );
  }
}

/// This class is used to display a list of holidays in a [ListView] widget
/// It takes a [holidays] parameter with a list of holidays
/// It takes a [user] parameter with the user information
///
/// On top of the [ListView], 3 [Button] are displayed to filter the list of holidays and can scroll horizontally if there are too many
/// There are 3 [Tout], [Congés validés] and [Congés refusés]
/// These [Button] are displayed only if the user is a manager or an admin

class HolidayList extends StatefulWidget {
  final List<Map<String, dynamic>> holidays;
  final Map<String, dynamic> user;

  const HolidayList({super.key, required this.holidays, required this.user});

  @override
  State<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {
  // The current filter
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    // Theme of context
    final ThemeData theme = Theme.of(context);

    // List of holidays
    List<Map<String, dynamic>> holidays = widget.holidays;
    // User information
    Map<String, dynamic> user = widget.user;

    // check if the user is a manager
    bool isManager = user['is_manager'];
    // check if the user is an admin
    bool isAdmin = user['is_admin'];

    // List of holidays filtered by the current filter
    List<Map<String, dynamic>> filteredHolidays = holidays.where((holiday) {
      if (_filter == 'all') {
        return true;
      } else if (_filter == 'validate') {
        return holiday['state'] == 'validate';
      } else if (_filter == 'refuse') {
        return holiday['state'] == 'refuse';
      } else {
        return false;
      }
    }).toList();

    // Buton action display in a scroll horizontally
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
                      _filter == 'all' ? theme.primaryColor : Colors.grey,
                ),
                child: const Text('Tout'),
              ),
              if (isManager || isAdmin)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filter = 'validate';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'validate'
                        ? theme.primaryColor
                        : Colors.grey,
                  ),
                  child: const Text('Congés validés'),
                ),
              if (isManager || isAdmin)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filter = 'refuse';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _filter == 'refuse' ? theme.primaryColor : Colors.grey,
                  ),
                  child: const Text('Congés refusés'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredHolidays.length,
            itemBuilder: (context, index) {
              return HolidayItem(
                key: ValueKey(index),
                holiday: filteredHolidays[index],
                user: user,
              );
            },
          ),
        ),
      ],
    );
  }
}
