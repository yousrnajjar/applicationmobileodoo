import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/core/widgets/hr_payslip/payslip_detail.dart';
import 'package:smartpay/ir/data/themes.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class PayslipListDetail extends PayslipDetail {
  final Function? onPrintPdf;

  PayslipListDetail({super.key, required super.pay, this.onPrintPdf});

  @override
  Widget buildBody(
      BuildContext context, DateTime date, Map<String, dynamic> lastPay) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var stateDisplay = pay.keys
        .firstWhere((k) => k.name == 'state')
        .selectionOptions
        .firstWhere((v) => v['value'] == lastPay['state'])['display_name'];
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
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fiche de paie pour le mois du',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
                Text(
                  // Mai 2021
                  //DateFormat('MMMM yyyy', 'fr_FR').format(date),
                  capitalize(DateFormat('MMMM yyyy', 'fr_FR').format(date)),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text(
                      'État : ',
                      style: TextStyle(
                        color: kGreen, //stateColor[lastPay['state']],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$stateDisplay',
                      style: const TextStyle(
                        color: kGreen, //stateColor[lastPay['state']],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? buildFooter(BuildContext context) {
    // pay.keys.forEach((element) {
    //   print(element.name);
    // });
    var id = pay.keys.firstWhere((k) => k.name == 'id');

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
              onPrintPdf!(pay[id]);
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
