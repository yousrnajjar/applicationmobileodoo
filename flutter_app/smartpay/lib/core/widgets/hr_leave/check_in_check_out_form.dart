import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/check_in_check_out_state.dart';
import 'package:smartpay/ir/models/employee.dart';

// Base size
var baseSize = const Size(319, 512);
var dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
var dateFormatter = DateFormat('yyyy-MM-dd');
var timeFormatter = DateFormat('HH:mm:ss');

class CheckInCheckOutForm extends StatefulWidget {
  final EmployeeAllInfo employee;

  const CheckInCheckOutForm({
    super.key,
    required this.employee,
  });

  @override
  State<CheckInCheckOutForm> createState() => _CheckInCheckOutFormState();
}

class _CheckInCheckOutFormState extends State<CheckInCheckOutForm> {
  // widthRatio
  double widthRatio = 1;
  double heightRatio = 1;
  DateTime now = DateTime.now();

  final Map<CheckInCheckOutFormState, String> _header = {
    CheckInCheckOutFormState.hourNotReached: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
    CheckInCheckOutFormState.canCheckIn: 'MERCI DE POINTER',
    CheckInCheckOutFormState.canCheckOut: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
  };

  ///Checkin, Checkout
  Future<Map<String, dynamic>> _check() async {
    var data = {
      "args": [
        [1],
        "hr_attendance.hr_attendance_action_my_attendances"
      ],
      "model": "hr.employee",
      "method": "attendance_manual",
      "kwargs": {
        "context": OdooModel.session.defaultContext,
      }
    };
    var response = await OdooModel.session.callKw(data);
    // if response have not action--> id key raise error
    if (response['action'] == null ||
        response['action']['id'] == null ||
        response['action']['attendance'] == null) {
      throw Exception('Error in check in');
    }

    //var response = await _makeCheckInCheckOutRequest();
    if (kDebugMode) {
      print('response: $response');
    }

    var attendance = response['action']['attendance'];
    DateTime? day;
    DateTime? checkIn;
    DateTime? checkOut;
    Duration? workedHours;
    try {
      //var checkIn = DateTime.parse(attendance['check_in']);
      checkIn = attendance['check_in'] != false
          ? dateTimeFormatter.parse(attendance['check_in'])
          : null;
      //var checkOut = attendance['check_out'] != false ? DateTime.parse(attendance['check_out']) : null;
      checkOut = attendance['check_out'] != false
          ? dateTimeFormatter.parse(attendance['check_out'])
          : null;
      day = checkIn != null
          ? dateFormatter.parse(dateFormatter.format(checkIn))
          : null;

      double hoursRaw = attendance['worked_hours'] != false
          ? attendance['worked_hours']
          : 0.0;

      workedHours = Duration(
          hours: hoursRaw.floor(),
          minutes: ((hoursRaw - hoursRaw.floor()) * 60).floor(),
          seconds: hoursRaw.floor() * 3600);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Error in check in');
    }

    return {
      'day': day,
      'startTime': checkIn,
      'endTime': checkOut,
      //'state: state,
      'workTime': workedHours,
    };
  }

  Future<Map<String, dynamic>> _getCheckInCheckOutInfo() async {
    List<Map<String, dynamic>> response = [];
    try {
      response = await OdooModel("hr.attendance").searchRead(
        domain: [
          ["employee_id", "=", widget.employee.id]
        ],
        fieldNames: ["check_in", "check_out", "worked_hours"],
        limit: 1,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Error in check in');
    }
    var attendance = response[0];
    CheckInCheckOutFormState? state;
    DateTime? day = attendance['check_in'] != false
        ? dateFormatter.parse(attendance['check_in'])
        : null;

    DateTime? startTime = attendance['check_in'] != false
        ? dateTimeFormatter.parse(attendance['check_in'])
        : null;

    // DateTime? endTime = attendance['check_out'] != false
    //     ? dateTimeFormatter.parse(attendance['check_out'])
    //     : null;

    double hoursRaw =
        attendance['worked_hours'] != false ? attendance['worked_hours'] : 0.0;
    Duration workTime = Duration(
        hours: hoursRaw.floor(),
        minutes: ((hoursRaw - hoursRaw.floor()) * 60).floor(),
        seconds: hoursRaw.floor() * 3600);
    // if current time in 08:00 - 18:00
    if (now.hour <= 8 && now.hour >= 18) {
      state = CheckInCheckOutFormState.hourNotReached;
    } else if (attendance['check_out'] == false) {
      state = CheckInCheckOutFormState.canCheckOut;
    } else if (attendance['check_out'] != false &&
        attendance['check_in'] != false) {
      state = CheckInCheckOutFormState.canCheckIn;
    }

    return {
      'workTime': workTime,
      'day': day,
      'startTime': startTime,
      'state': state
    };
  }

  Future<Map<String, dynamic>> _getOrCheck({bool check = false}) async {
    if (check) {
      return _check();
    } else {
      return _getCheckInCheckOutInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    widthRatio = width / baseSize.width;
    heightRatio = height / baseSize.height;

    // Add RefreshIndicator
    return RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
            future: _getOrCheck(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (kDebugMode) {
                  print('CheckInCheckOutForm build data: $data');
                }
                var workTime = data['workTime'];
                var day = data['day'];
                var startTime = data['startTime'];
                var endTime = data['endTime'];
                var state = data['state'];
                if (kDebugMode) {
                  print('CheckInCheckOutForm build state: $state');
                }

                var haveSubHeader1 =
                    ([CheckInCheckOutFormState.canCheckIn].contains(state));
                var haveSubHeader2 = true;
                var haveStartTime = ([
                  CheckInCheckOutFormState.canCheckOut,
                  CheckInCheckOutFormState.hourNotReached
                ].contains(state));
                var haveEndTime =
                    ([CheckInCheckOutFormState.hourNotReached].contains(state));
                var haveCheckInButton =
                    ([CheckInCheckOutFormState.canCheckIn].contains(state));
                var haveCheckOutButton =
                    ([CheckInCheckOutFormState.canCheckOut].contains(state));

                return Container(
                    padding: EdgeInsets.only(
                      left: 20 * widthRatio,
                      right: 20 * widthRatio,
                      top: 30 * heightRatio,
                      bottom: 30 * heightRatio,
                    ),
                    child: ListView(children: [
                      Column(
                        children: [
                          _buildHeader(context, state: state),
                          // subHeader1
                          SizedBox(
                            height: 5 * heightRatio,
                          ),
                          if (haveSubHeader1) _buildSubHeader1(context),
                          // subHeader2
                          SizedBox(
                            height: 5 * heightRatio,
                          ),
                          if (haveSubHeader2)
                            _buildSubHeader2(context, day: day),
                          // startTime
                          SizedBox(
                            height: 10 * heightRatio,
                          ),
                          if (haveStartTime)
                            _buildStartTime(context, startTime: startTime),
                          // endTime
                          if (haveEndTime)
                            _buildEndTime(context, endTime: endTime),
                          SizedBox(
                            height: 5 * heightRatio,
                          ),
                          // workTime
                          _buildWorkTime(context, workTime: workTime),
                          SizedBox(
                            height: 5 * heightRatio,
                          ),
                          // checkInButton
                          if (haveCheckInButton) _buildCheckInButton(context),
                          // checkOutButton
                          if (haveCheckOutButton) _buildCheckOutButton(context),
                        ],
                      )
                    ]));
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Widget _buildHeader(BuildContext context, {CheckInCheckOutFormState? state}) {
    var headerTextStyle = TextStyle(
      fontSize: 18 * widthRatio,
      fontWeight: FontWeight.bold,
      color: kGreen,
    );

    return Text(
      _header[state] ?? '',
      textAlign: TextAlign.center,
      style: headerTextStyle,
    );
  }

  Widget _buildSubHeader1(BuildContext context) {
    var headerText = "DÈS LE DÉMARRAGE DE LA JOURNÉE";
    var textStyle = TextStyle(
      fontSize: 14 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Text(
      headerText,
      style: textStyle,
    );
  }

  Widget _buildSubHeader2(BuildContext context, {DateTime? day}) {
    var dateText = "DATE : ";
    if (day != null) {
      dateText += dateFormatter.format(day);
    } else {
      dateText += dateFormatter.format(DateTime.now());
    }
    var dateTextStyle = TextStyle(
      fontSize: 12 * widthRatio,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    );

    return Text(
      dateText,
      style: dateTextStyle,
    );
  }

  Widget _buildStartTime(BuildContext context, {DateTime? startTime}) {
    var startTimeText = "DÉBUT D'ACTIVITÉ: ";
    if (startTime != null) {
      startTimeText += timeFormatter.format(startTime);
    } else {
      startTimeText += "00:00";
    }
    var timeTextStyle = TextStyle(
      fontSize: 12 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Text(
      startTimeText,
      style: timeTextStyle,
    );
  }

  Widget _buildEndTime(BuildContext context, {DateTime? endTime}) {
    var endTimeText = "FIN D'ACTIVITÉ: ";
    if (endTime != null) {
      endTimeText += timeFormatter.format(endTime);
    } else {
      endTimeText += "00:00";
    }
    var timeTextStyle = TextStyle(
      fontSize: 12 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Text(
      endTimeText,
      style: timeTextStyle,
    );
  }

  Widget _buildWorkTime(BuildContext context, {Duration? workTime}) {
    var workTimeTextStyle = TextStyle(
      fontSize: 37 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    var workTimeText = "";
    if (workTime != null) {
      workTimeText = workTime.toString().substring(0, 7);
    } else {
      workTimeText = "00:00:00";
    }

    return Text(
      workTimeText,
      style: workTimeTextStyle,
    );
  }

  /// CheckInButton
  /// Le contenu du bouton est :
  ///   - "DÉMARRER"
  ///   - un icône de flèche vers la droite du style `>`
  ///En dessous du bouton, il y a un texte : "Cliquer pour démarrer"

  Widget _buildCheckInButton(BuildContext context) {
    const checkInButtonText = "DÉMARRER";
    var checkInButtonTextStyle = TextStyle(
      fontSize: 18 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return Container(
      width: 200 * widthRatio,
      height: 50 * heightRatio,
      alignment: Alignment.center,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _getOrCheck(check: true).then((value) => {setState(() {})});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  checkInButtonText,
                  style: checkInButtonTextStyle,
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_right_alt,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5 * heightRatio,
          ),
          Text(
            "Cliquer pour démarrer",
            style: TextStyle(
              fontSize: 12 * widthRatio,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// CheckOutButton
  /// Le contenu du bouton est :
  ///   - "CLÔTURER LA JOURNÉE"

  Widget _buildCheckOutButton(BuildContext context) {
    const checkOutButtonText = "CLÔTURER LA JOURNÉE";
    var checkOutButtonTextStyle = TextStyle(
      fontSize: 12 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return Container(
      width: 200 * widthRatio,
      height: 50 * heightRatio,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          _getOrCheck(check: true).then((value) => {setState(() {})});
        },
        child: Text(
          checkOutButtonText,
          style: checkOutButtonTextStyle,
        ),
      ),
    );
  }
}
