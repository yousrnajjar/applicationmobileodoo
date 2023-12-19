import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/exceptions/api_exceptions.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/allocation.dart';
import 'package:smartpay/ir/models/check_in_check_out_state.dart';
import 'package:smartpay/ir/models/employee.dart';

import '../utils/qr_bare_code.dart';
import 'clock_animation.dart';
import 'hr_attendance.dart';

// Base size
var baseSize = const Size(319, 512);

enum CheckInType { manual, qrCode, code }

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

  final Map<CheckInCheckOutState, String> _header = {
    CheckInCheckOutState.hourNotReached: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
    CheckInCheckOutState.canCheckIn: 'MERCI DE POINTER',
    CheckInCheckOutState.canCheckOut: 'DURÉE DE LA JOURNÉE DU TRAVAIL',
  };

  // bool _enteringCode = false;

  String? checkError;

  @override
  void initState() {
    super.initState();
    attendance = HrAttendance(widget.employee.id!);
  }

  @override
  Widget build(BuildContext context) {
    if (checkError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkError!),
        ),
      );
    }
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
                          if (haveCheckInButton) _buildCheckInButtons(),
                          // checkOutButton
                          if (haveCheckOutButton)
                            CheckInButton(
                              heightRatio: heightRatio,
                              widthRatio: widthRatio,
                              text: "CLÔTURER LA JOURNÉE",
                              icon: const Icon(
                                Icons.arrow_right_alt,
                                color: Colors.white,
                              ),
                              onClick: checkOutAction,
                            ),
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

  Future<void> onCheckIn() async {
    try {
      await checkIn();
      setState(() {});
    } catch (e) {
      // Message d'erreur dans l'interface utilisateur
      if (context.mounted) {
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
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _check() async {
    return await attendance.getOrCheck(check: true);
  }

  Future<Map<String, dynamic>?> checkIn() async {
    return await _check();
  }

  Future<Map<String, dynamic>?> checkOut() async {
    return await _check();
  }

  Future<void> checkInAction(CheckInType type) async {
    bool canCheckIn = true;
    if (type == CheckInType.qrCode) {
      canCheckIn = await checkInQRCodeValid();
    } else if (type == CheckInType.code) {
      canCheckIn = await checkCodeValid();
    }
    if (canCheckIn) {
      try {
        await checkIn();
      } on OdooErrorException catch (e) {
        onCheckError(e);
      }
    }
    setState(() {});
  }

  void checkOutAction() async {
    try {
      await checkOut();
      setState(() {});
    } on OdooErrorException catch (e) {
      onCheckError(e);
    } catch (e) {
      // Message d'erreur dans l'interface utilisateur
      if (context.mounted){
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
    }
  }

  void onCheckError(OdooErrorException e) {
    if (e.errorType != 'user_error') {
      throw e;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.message,
          style: TextStyle(
            fontSize: 12 * widthRatio,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
    );
    setState(() {});
  }

  /// CheckInButtons

  Widget _buildCheckInButtons() {
    return ListView(
      shrinkWrap: true,
      children: [
        CheckInButton(
          heightRatio: heightRatio,
          widthRatio: widthRatio,
          text: "POINTAGE MANUELLE",
          icon: const Icon(
            Icons.arrow_right_alt,
            color: Colors.white,
          ),
          onClick: () async {
            await checkInAction(CheckInType.manual);
          },
        ),
        SizedBox(
          height: 5 * heightRatio,
        ),
        CheckInButton(
          heightRatio: heightRatio,
          widthRatio: widthRatio,
          text: "SCANNEZ LE CODE",
          icon: Image.asset(
            "assets/icons/barcode_scanner.png",
            width: 20 * widthRatio,
            height: 20 * heightRatio,
            color: Colors.white,
          ),
          onClick: () async {
            await checkInAction(CheckInType.qrCode);
          },
        ),
        SizedBox(
          height: 5 * heightRatio,
        ),
        CheckInButton(
          heightRatio: heightRatio,
          widthRatio: widthRatio,
          text: "ENTREZ LE CODE PIN",
          icon: Image.asset(
            "assets/icons/vpn_key.png",
            width: 20 * widthRatio,
            height: 20 * heightRatio,
            color: Colors.white,
          ),
          onClick: () async {
            await checkInAction(CheckInType.code);
          },
        )
      ],
    );
  }

  Future<bool> checkCodeValid() async {
    setState(() {
      // _enteringCode = true;
    });
    final code = await showDialog(
      context: context,
      builder: (context) => const EnterCodeDialog(),
    );
    setState(() {
      // _enteringCode = false;
    });
    if (code == null) {
      return false;
    }
    var emps = await OdooModel('hr.employee').searchRead(
      domain: [
        ['id', '=', widget.employee.id],
        ['pin', '=', code]
      ],
      fieldNames: ['pin'],
    );
    if (emps.isEmpty) {
      if (context.mounted) {
        // Message d'erreur dans l'interface utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors du démarrage de la journée: Code PIN érroné",
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
      return false;
    }
    return true;
  }

  Future<bool> checkInQRCodeValid() async {
    final String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const QRViewWidget(),
      ),
    );
    if (result == null) {
      return false;
    }
    var emps = await OdooModel('hr.employee').searchRead(
      domain: [
        ['id', '=', widget.employee.id],
        ['barcode', '=', result]
      ],
      fieldNames: ['barcode'],
    );
    if (emps.isEmpty) {
      if (context.mounted) {
        // Message d'erreur dans l'interface utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors du démarrage de la journée: Code érroné",
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
      return false;
    }
    return true;
  }
}

/// EnterCodeDialog
/// Boite de dialogue demandant le code PIN
/// Le contenu de la boite de dialogue est :
///   - "Entrez le code PIN"
///   - "Champ de saisie du code PIN"
///   - "Bouton de validation"
/// Au clic sur le bouton de validation, on retourne le code PIN saisi

class EnterCodeDialog extends StatefulWidget {
  const EnterCodeDialog({super.key});

  @override
  EnterCodeDialogState createState() => EnterCodeDialogState();
}

class EnterCodeDialogState extends State<EnterCodeDialog> {
  final _pinCodeController = TextEditingController();
  double widthRatio = 1;
  double heightRatio = 1;

  @override
  Widget build(BuildContext context) {
    const enterCodeDialogText = "Entrez le code PIN";
    var enterCodeDialogTextStyle = TextStyle(
      fontSize: 16 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      backgroundColor: Colors.white,
      title: const Text(enterCodeDialogText),
      titleTextStyle: enterCodeDialogTextStyle,
      actionsAlignment: MainAxisAlignment.center,
      icon: Image.asset(
        "assets/icons/vpn_key.png",
        width: 30 * widthRatio,
        height: 30 * heightRatio,
        color: Colors.black,
      ),
      actions: [
        _buildValidationButton(context),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10 * heightRatio,
          ),
          TextField(
            controller: _pinCodeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Code PIN',
            ),
          )
        ],
      ),
    );
  }

  /// ValidationButton
  /// Le contenu du bouton est :
  ///   - "VALIDER"
  /// Au clic sur le bouton, on retourne le code PIN saisi

  Widget _buildValidationButton(BuildContext context) {
    const validationButtonText = "VALIDER";
    var validationButtonTextStyle = TextStyle(
      fontSize: 12 * widthRatio,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    return Container(
      width: double.infinity,
      height: 30 * heightRatio,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context, _pinCodeController.text);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              validationButtonText,
              style: validationButtonTextStyle,
            ),
            const Spacer(),
            const Icon(
              Icons.check,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class CheckInButton extends StatefulWidget {
  final double heightRatio;
  final double widthRatio;
  final String text;
  final Function() onClick;
  final Widget icon;

  const CheckInButton({
    super.key,
    required this.heightRatio,
    required this.widthRatio,
    required this.onClick,
    required this.text,
    required this.icon,
  });

  @override
  State<StatefulWidget> createState() {
    return _CheckInButtonState();
  }
}

class _CheckInButtonState extends State<CheckInButton> {
  bool _isCheckInButtonLoading = false;
  final String _loadingText = "Veuillez patienter...";

  @override
  Widget build(BuildContext context) {
    if (_isCheckInButtonLoading) {
      return _buildLoading(context);
    }
    return _buildCheckInButton(context);
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      width: widget.widthRatio * 200,
      height: widget.heightRatio * 40,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_loadingText),
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
            widget.icon
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context) {
    var checkInButtonTextStyle = TextStyle(
      fontSize: widget.heightRatio * 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      height: widget.heightRatio * 40,
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            height: 5 * widget.heightRatio,
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isCheckInButtonLoading = true;
              });
              try {
                await widget.onClick();
              } finally {
                setState(() {
                  _isCheckInButtonLoading = false;
                });
              }
            },
            child: SizedBox(
              width: widget.widthRatio * 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.text,
                    style: checkInButtonTextStyle,
                  ),
                  const Spacer(),
                  widget.icon,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
