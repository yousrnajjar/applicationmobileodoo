import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';

import '../utils/month_card.dart';

class ContractDetail extends StatelessWidget {
  final Map<OdooField, dynamic> contract;

  final Function? onPrintPdf;

  ContractDetail({
    super.key,
    required this.contract,
    this.onPrintPdf,
  });

  final Map<String, Color> stateColor = {
    'draft': kGrey,
    'open': kGreen,
    'close': kPink,
    'cancel': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> lastContact = {};
    contract.forEach((k, v) {
      lastContact[k.name] = v;
    });
    var height = MediaQuery.of(context).size.height;
    var itemHeight = (86 / baseHeightDesign) * height;


    // Si aucune fiche de pay n'est disponible
    if (contract.isEmpty) {
      return Container(
        height: itemHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(
              55, 248, 187, 220), //Color.fromARGB(255, 191, 248, 187),
        ),
        child: const Center(
          child: Text('Pas de contrat disponible pour le moment'),
        ),
      );
    }
    var date = DateTime.now();
    var footer = buildFooter(context, itemHeight);
    return Row(children: [
      buildMonth(date, kLightPink, textColor: Colors.black),
      buildBody(context, DateTime.now(), lastContact, itemHeight),
      if (footer != null)
        // footer, --> Add vertical line
        Container(
          width: 1,
          height: itemHeight,
          color: Colors.black,
        ),
      if (footer != null) footer,
    ]);
  }

  Widget buildMonth(DateTime date, backgroundColor, {Color? textColor}) {
    return MonthCard(
        date: date, backgroundColor: backgroundColor, textColor: textColor);
  }

  Widget buildBody(
      BuildContext context, DateTime date, Map<String, dynamic> lastContract, double itemHeight) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    String numberOfMonthInContractString = '';
    var stateDisplay = contract.keys
        .firstWhere((k) => k.name == 'state')
        .selectionOptions
        .firstWhere((v) => v['value'] == lastContract['state'])['display_name'];

    var dateFormatter = DateFormat('yyyy-MM-dd');
    if (kDebugMode) {
      print(lastContract['date_start']);
      print(lastContract['date_end']);
    }
    if (lastContract['date_start'] == false ||
        lastContract['date_end'] == false) {
      numberOfMonthInContractString = '-';
    } else {
      DateTime dateStart = dateFormatter.parse(lastContract['date_start']);
      DateTime dateEnd = dateFormatter.parse(lastContract['date_end']);
      // Compute the number of year in the contract
      // if the contract has no end date, then replace with : infinity
      // else compute the number of month between [dateStart] and [dateEnd]
      var numberOfMonthInContract =
          (dateEnd.difference(dateStart).inDays / 365);
      // pad the number of month with 0 if it's less than 10 and replace with 'Indéterminé' if it's infinite
      numberOfMonthInContractString =
          '${numberOfMonthInContract.toStringAsFixed(0).padLeft(2, '0')}An';
    }
    return Expanded(
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
            child: Column(
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
                      stateDisplay,
                      style: const TextStyle(
                        color: kGreen,
                        // FixME: Get right color with status
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  Widget? buildFooter(BuildContext context, double itemHeight) {
    var id = contract.keys.firstWhere((k) => k.name == 'id');

    return Container(
      height: itemHeight,
      width: (93 / baseWidthDesign) * MediaQuery.of(context).size.width,
      // Ligne de séparation noire
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 230, 229, 225),
        border: Border(
          left: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              if (onPrintPdf == null) {
                return;
              }
              onPrintPdf!(contract[id]);
            },
            style: TextButton.styleFrom(
              foregroundColor: kGreen,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.all(5),
              shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0))),
              textStyle: const TextStyle(
                fontSize: 11,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/telechargement.png',
                  width: 30,
                  height: 30,
                ),
                const Text(
                  'Consulter',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
