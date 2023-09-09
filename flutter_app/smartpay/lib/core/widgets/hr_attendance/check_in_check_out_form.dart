import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/models/allocation.dart';
import 'package:smartpay/ir/models/check_in_check_out_state.dart';
import 'package:smartpay/ir/models/employee.dart';

import 'clock_animation.dart';
import 'hr_attendance.dart';

// Base size
var baseSize = const Size(319, 512);

class CheckInCheckOutForm extends StatefulWidget {
  final EmployeeAllInfo employee;

  const CheckInCheckOutForm({
    super.key,
    required this.employee,
  });

  @override
  State<CheckInCheckOutForm> createState() => CheckInCheckOutFormState();
}

class CheckInCheckOutFormState extends State<CheckInCheckOutForm> {
  // widthRatio
  double widthRatio = 1;
  double heightRatio = 1;
  DateTime now = DateTime.now();
  late HrAttendance attendance;
  bool _isCheckOutButtonLoading = false;
  bool _isCheckInButtonLoading = false;

  final Map<CheckInCheckOutState, String> _header = {
    CheckInCheckOutState.hourNotReached: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
    CheckInCheckOutState.canCheckIn: 'MERCI DE POINTER',
    CheckInCheckOutState.canCheckOut: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
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
              'state': CheckInCheckOutState.hourNotReached,
              'workTime': null,
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
                var workTime = data['workTime'];
                if (kDebugMode) {
                  print('CheckInCheckOutForm build state: $state');
                }
                
                // Jour aujourdhui si canCheckIn
                if (state == CheckInCheckOutState.canCheckIn) {
                  day = dayFormatter.parse(dayFormatter.format(DateTime.now()));
                }

                var haveSubHeader1 =
                    ([CheckInCheckOutState.canCheckIn].contains(state));
                var haveSubHeader2 = true;
                var haveStartTime = ([
                  CheckInCheckOutState.canCheckOut,
                  CheckInCheckOutState.hourNotReached
                ].contains(state));
                var haveEndTime =
                    ([CheckInCheckOutState.hourNotReached].contains(state));
                var haveCheckInButton =
                    ([CheckInCheckOutState.canCheckIn].contains(state));
                var haveCheckOutButton =
                    ([CheckInCheckOutState.canCheckOut].contains(state));
                var haveWorkTime = ([
                  CheckInCheckOutState.canCheckOut,
                  CheckInCheckOutState.hourNotReached
                ].contains(state));

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
                          if (haveWorkTime)
                            _buildWorkTime(context, state, workTime),
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

  Widget _buildHeader(BuildContext context, {CheckInCheckOutState? state}) {
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

  Widget _buildWorkTime(
      BuildContext context, CheckInCheckOutState state, Duration? workTime) {
    var workTimeTextStyle = TextStyle(
      fontSize: 37 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    if (state == CheckInCheckOutState.canCheckOut) {
      return ClockAnimation(
        startDuration: workTime ?? const Duration(),
        textStyle: workTimeTextStyle,
      );
    }
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
    if (_isCheckInButtonLoading) {
      return Container(
        width: 200 * widthRatio,
        height: 50 * heightRatio,
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Veuillez patienter..."),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_right_alt,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      width: 200 * widthRatio,
      height: 50 * heightRatio,
      alignment: Alignment.center,
      child: Column(
        children: [
            ElevatedButton(
            onPressed: () async {
              setState(() {
                _isCheckInButtonLoading = true;
              });
              await onCheckIn();
              setState(() {
                _isCheckInButtonLoading = false;
              });
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

  Future<void> onCheckIn() async {
    try {
      await checkIn();
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
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkIn() async {
    return await attendance.getOrCheck(check: true);
  }
  Future<Map<String, dynamic>> checkOut() async {
    return await attendance.getOrCheck(check: true);
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
    if (_isCheckOutButtonLoading) {
      return Container(
        width: 200 * widthRatio,
        height: 50 * heightRatio,
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Veuillez patienter jusqu'à la fin du chargement",
                  style: TextStyle(
                    fontSize: 12 * widthRatio,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_right_alt,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      width: 200 * widthRatio,
      height: 50 * heightRatio,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            _isCheckOutButtonLoading = true;          
          });
          try {
            await checkOut();
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
          } finally {
            // Activer le bouton
            setState(() {
              _isCheckOutButtonLoading = false;
            });
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
