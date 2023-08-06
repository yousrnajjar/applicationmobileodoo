import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/core/widgets/hr_attendance2/hr_attendance.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/allocation.dart';
import 'package:smartpay/ir/models/check_in_check_out_state.dart';
import 'package:smartpay/ir/models/employee.dart';

// Base size
var baseSize = const Size(319, 512);

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
  late HrAttendance attendance;

  final Map<CheckInCheckOutFormState, String> _header = {
    CheckInCheckOutFormState.hourNotReached: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
    CheckInCheckOutFormState.canCheckIn: 'MERCI DE POINTER',
    CheckInCheckOutFormState.canCheckOut: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
  };

  @override
  void initState() {
    super.initState();
    attendance = HrAttendance(widget.employee.id!);
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
            initialData: {
              'success': true,
              'message': '',
              'day': dayFormatter.parse(dayFormatter.format(DateTime.now())),
              'startTime': null,
              'state': CheckInCheckOutFormState.hourNotReached
            },
            future: attendance.getOrCheck(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (kDebugMode) {
                print(snapshot);
              }
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (kDebugMode) {
                  print('CheckInCheckOutForm build data: $data');
                }
                if (data['success'] == false) {
                  return Center(
                    child: Text(data['message']),
                  );
                }
                //var workTime = data['workTime'];
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
                          _buildWorkTime(context),
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

  Widget _buildWorkTime(BuildContext context) {
    var workTimeTextStyle = TextStyle(
      fontSize: 37 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    return FutureBuilder(
      initialData: const {"worked_hours": 0.0},
      future: attendance.getLatestAttendance(),
      builder: (context, snapshot) {
        var text = "--:--:--";
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          if (kDebugMode) {
            print(snapshot.data!);
          }
          double wh = snapshot.data!['worked_hours'];
          int h = wh.toInt();
          double minRestant = (wh - h) * 60;
          int m = minRestant.toInt();
          double secRestant = (minRestant - m) * 60;
          int s = secRestant.toInt();
          text =
              "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
        }
        return Text(text, style: workTimeTextStyle);
      },
    );
  }

  /// CheckInButtonwh
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
            onPressed: () async {
              //_getOrCheck(check: true).then((value) => {setState(() {})});
              try {
                await attendance.getOrCheck(check: true);
                setState(() {});
              } catch (e) {
                // Message d'erreur dans l'interface utilisateur
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Erreur lors du démarrage de la journée: $e",
                      style: TextStyle(
                        fontSize: 12 * widthRatio,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
        onPressed: () async {
          //_getOrCheck(check: true).then((value) => {setState(() {})});
          try {
            await attendance.getOrCheck(check: true);
            setState(() {});
          } catch (e) {
            // Message d'erreur dans l'interface utilisateur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Erreur lors de la clôture de la journée: $e",
                  style: TextStyle(
                    fontSize: 12 * widthRatio,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Text(
          checkOutButtonText,
          style: checkOutButtonTextStyle,
        ),
      ),
    );
  }
}
