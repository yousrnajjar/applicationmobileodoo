import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';

class ContractDetail extends StatelessWidget {

  final Map<OdooField, dynamic> contract;

  const ContractDetail({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var itemHeight = (86 / baseHeightDesign) * height;
    var itemWidth = (60 / baseWidthDesign) * width;

    // Si aucune fiche de pay n'est disponible
    if (contract.isEmpty) {
      return Container(
        height: itemHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(
              255, 248, 187, 220), //Color.fromARGB(255, 191, 248, 187),
        ),
        child: const Center(
          child: Text('Pas de contrat disponible pour le moment'),
        ),
      );
    }
    Map<String, Color> stateColor = {
      'draft': kGrey,
      'open': kGreen,
      'close': kPink,
      'cancel': Colors.red,
    };

    Map<String, dynamic> contractDisplay = {};
    contract.forEach((k, v) {
      contractDisplay[k.name] = v;
    });
    String numberOfMonthInContractString = '';
    String stateString = '';

    var dateFormatter = DateFormat('yyyy-MM-dd');
    if (kDebugMode) {
      print(contractDisplay['date_start']);
      print(contractDisplay['date_end']);
    }
    if (contractDisplay['date_start'] == false || contractDisplay['date_end'] == false) {
      numberOfMonthInContractString = '-';
    } else {
      DateTime dateStart = dateFormatter.parse(contractDisplay['date_start']);
      DateTime dateEnd = dateFormatter.parse(contractDisplay['date_end']);
      // Compute the number of year in the contract
      // if the contract has no end date, then replace with : infinity
      // else compute the number of month between [dateStart] and [dateEnd]
      var numberOfMonthInContract =
      (dateEnd.difference(dateStart).inDays / 365) as int;
      // pad the number of month with 0 if it's less than 10 and replace with 'Indéterminé' if it's infinite
      numberOfMonthInContractString =
      '${numberOfMonthInContract.toStringAsFixed(0).padLeft(2, '0')}An';
    }

    String state = contractDisplay['state'];
    stateString = contract.keys
        .firstWhere((element) => element.name == 'state')
        .selectionOptions
        .firstWhere((element) => element['value'] == state)['display_name'];
    return Row(children: [
      Container(
        height: itemHeight,
        width: itemWidth,
        padding: EdgeInsets.only(
          top: (25 / baseHeightDesign) * height,
        ),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 248, 187, 220),
        ),
        child: Column(children: [
          const Text(
            'Mois',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            DateTime.now().month.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]),
      ),
      Expanded(
        child: Container(
          height: itemHeight,
          width: double.infinity,
          padding: EdgeInsets.only(
            top: (12 / baseHeightDesign) * height,
            left: (10 / baseWidthDesign) * width,
            right: (10 / baseWidthDesign) * width,
          ),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 230, 229, 225),
          ),
          child: Row(children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Etat du contrat',
                    style: TextStyle(
                      color: kGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Durée: ',
                        style: TextStyle(
                          color: kGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        numberOfMonthInContractString,
                        style: const TextStyle(
                          color: kGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'Type de contrat : ',
                        style: TextStyle(
                          color: kGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'TODO',
                        style: TextStyle(
                          color: kGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'État : ',
                        style: TextStyle(
                          color: kGreen,
                          // FixME: Get right color with status
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        stateString,
                        style: const TextStyle(
                          color: kGreen,
                          // FixME: Get right color with status
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '+ ',
                        style: TextStyle(
                          color: kGrey,
                          // FixME: Get right color with status
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: kGreen,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.all(5),
                            shape: const BeveledRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(0))),
                            textStyle: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          child: const Text('Consulter le contrat'),
                          onPressed: () {
                            // Modal to display contract
                            // state , wage, name, date_start, date_end, trial_date_end, resource_calendar_id, hr_responsible_id.

                            var state = contractDisplay['state'];
                            var stateString = contract.keys
                                .firstWhere(
                                    (element) => element.name == 'state')
                                .selectionOptions
                                .firstWhere((element) =>
                            element['value'] == state)['display_name'];
                            var wage = contractDisplay['wage'];
                            var name = contractDisplay['name'];
                            var dateStart = contractDisplay['date_start'];
                            var dateEnd = contractDisplay['date_end'];
                            var trialDateEnd = contractDisplay['trial_date_end'];
                            var resourceCalendarName =
                            contractDisplay['resource_calendar_id'][1];
                            var hrResponsibleName =
                            contractDisplay['hr_responsible_id'] == false
                                ? ''
                                : contractDisplay['hr_responsible_id'][1];

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(name),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text('État : $stateString'),
                                        Text('Salaire : $wage'),
                                        Text('Nom : $name'),
                                        Text('Date de début : $dateStart'),
                                        Text('Date de fin : $dateEnd'),
                                        Text(
                                            'Date de fin d\'essai : $trialDateEnd'),
                                        Text(
                                            'Heure de travail : $resourceCalendarName'),
                                        Text(
                                            'Responsable RH : $hrResponsibleName'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Fermer'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          })
                    ],
                  ),
                ]),
            const Spacer(),
            Center(
                child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: kGrey,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(5),
                      shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0))),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Consulter le contrat'),
                    onPressed: () {}))
          ]),
        ),
      ),
    ]);
  }
}
